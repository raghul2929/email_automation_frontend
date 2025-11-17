import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/storage_helper.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();

  // Google Sign-In with retry logic
  Future<User?> signInWithGoogle({int retryCount = 0}) async {
    try {
      // Clear any cached credentials
      await _googleSignIn.signOut();
      await _auth.signOut();

      _logger.d('Starting Google Sign-In... (Attempt ${retryCount + 1})');

      // Get Google account
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.w('User cancelled Google Sign-In');
        return null;
      }

      _logger.d('Google Sign-In successful: ${googleUser.email}');

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        _logger.e('Failed to get authentication tokens');
        throw Exception('No authentication tokens received');
      }

      _logger.d('Got authentication tokens');

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        // Sign in to Firebase with retry
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        _logger.d('Firebase sign-in successful: ${userCredential.user?.email}');

        return userCredential.user;
      } on FirebaseAuthException catch (e) {
        _logger.e('Firebase Auth Error: ${e.code} - ${e.message}');

        // Retry on network errors
        if ((e.code == 'network-request-failed' || e.code == 'unknown') &&
            retryCount < 2) {
          _logger.d('Retrying Firebase sign-in...');
          await Future.delayed(Duration(seconds: 2));
          return await signInWithGoogle(retryCount: retryCount + 1);
        }

        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('Google Sign-In Error: $e');
      _logger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Register User
  // Register User
  Future<UserModel> registerUser({
    required String uid,
    required String name,
    required String email,
    required String profession,
  }) async {
    try {
      _logger.d('Registering user: $email');

      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'uid': uid,
          'name': name,
          'email': email,
          'profession': profession,
        },
      );

      _logger.d('Registration response: ${response.data}');

      // Save JWT Token
      final token = response.data['token'];
      if (token != null) {
        await StorageHelper.saveToken(token);
        _logger.d('JWT token saved');
      }

      // ✅ Backend returns 'data' object with 'userId' field
      final userData = response.data['data'];

      if (userData == null) {
        throw Exception('No user data in response');
      }

      _logger.d('User data from backend: $userData');
      _logger.d('MongoDB userId: ${userData['userId']}'); // ✅ Add this log

      // ✅ CRITICAL FIX: Use 'userId' field from backend (MongoDB _id)
      await StorageHelper.saveUserData(
        userId: userData['userId'], // ✅ This is MongoDB _id from backend!
        email: userData['email'] ?? email,
        name: userData['name'] ?? name,
      );

      _logger.d('Saved userId to storage: ${userData['userId']}');

      // Create UserModel
      return UserModel(
        uid: userData['uid'] ?? uid,
        name: userData['name'] ?? name,
        email: userData['email'] ?? email,
        profession: userData['profession'] ?? profession,
        isActive: userData['isActive'] ?? true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      _logger.e('Registration Error: $e');
      _logger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Future<UserModel> registerUser({
  //   required String uid,
  //   required String name,
  //   required String email,
  //   required String profession,
  // }) async {
  //   try {
  //     _logger.d('Registering user: $email');

  //     final response = await _apiService.post(
  //       ApiConstants.register,
  //       data: {
  //         'uid': uid,
  //         'name': name,
  //         'email': email,
  //         'profession': profession,
  //       },
  //     );

  //     _logger.d('Registration response: ${response.data}');

  //     // Save JWT Token
  //     final token = response.data['token'];
  //     if (token != null) {
  //       await StorageHelper.saveToken(token);
  //       _logger.d('JWT token saved');
  //     }

  //     // Backend returns 'data' not 'user'
  //     final userData = response.data['data'] ?? response.data['user'];

  //     if (userData == null) {
  //       throw Exception('No user data in response');
  //     }

  //     // Save User Data
  //     await StorageHelper.saveUserData(
  //       userId: userData['userId'] ?? userData['uid'] ?? uid,
  //       email: userData['email'] ?? email,
  //       name: userData['name'] ?? name,
  //     );

  //     _logger.d('User data saved successfully');

  //     // Create UserModel
  //     return UserModel(
  //       uid: userData['uid'] ?? uid,
  //       name: userData['name'] ?? name,
  //       email: userData['email'] ?? email,
  //       profession: userData['profession'] ?? profession,
  //       isActive: userData['isActive'] ?? true,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //     );
  //   } catch (e, stackTrace) {
  //     _logger.e('Registration Error: $e');
  //     _logger.e('Stack trace: $stackTrace');
  //     rethrow;
  //   }
  // }

  // Get User by UID
// Get User by UID
// Get User by UID
Future<UserModel?> getUserByUid(String uid) async {
  try {
    _logger.d('Fetching user by UID: $uid');

    final response = await _apiService.get('${ApiConstants.getUserByUid}/$uid');

    _logger.d('Get user response: ${response.statusCode}');

    if (response.statusCode == 200) {
      // ✅ IMPORTANT: Get token from response (backend now returns it!)
      final token = response.data['token'];
      final userData = response.data['data'];

      if (userData == null) {
        _logger.w('No user data in response');
        return null;
      }

      _logger.d('User data: $userData');

      // ✅ CRITICAL: Save JWT token from backend
      if (token != null) {
        await StorageHelper.saveToken(token);
        _logger.d('✅ JWT token saved (length: ${token.length})');
      } else {
        _logger.w('⚠️ No JWT token in response - backend may need update');
      }

      // ✅ Save MongoDB userId to storage
      await StorageHelper.saveUserData(
        userId: userData['_id'],
        email: userData['email'],
        name: userData['name'],
      );

      _logger.d('✅ MongoDB userId saved: ${userData['_id']}');

      return UserModel.fromJson(userData);
    }

    return null;
  } catch (e) {
    _logger.w('Get User Error (user may not exist): $e');
    return null;
  }
}

  // Logout
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await StorageHelper.clearAll();
      _logger.d('Logout successful');
    } catch (e) {
      _logger.e('Logout Error: $e');
      rethrow;
    }
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
