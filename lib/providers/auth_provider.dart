import 'package:email_automation_app/core/utils/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  UserModel? _currentUser;
  User? _firebaseUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  User? get firebaseUser => _firebaseUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;


    Future<void> checkAuthState() async {
    try {
      _logger.d('Checking auth state...');
      
      // Check Firebase auth state
      final firebaseUser = _authService.getCurrentUser();
      
      if (firebaseUser == null) {
        _logger.d('No Firebase user found');
        return;
      }

      _logger.d('Firebase user found: ${firebaseUser.email}');

      // Check if we have JWT token
      final token = await StorageHelper.getToken();
      
      if (token == null) {
        _logger.w('No JWT token found, user needs to login again');
        await _authService.logout();
        return;
      }

      _logger.d('JWT token found');

      // Get user data from backend
      final user = await _authService.getUserByUid(firebaseUser.uid);
      
      if (user != null) {
        _currentUser = user;
        _logger.d('✅ User restored: ${user.email}');
        notifyListeners();
      } else {
        _logger.w('User not found in backend, logging out');
        await _authService.logout();
      }
      
    } catch (e) {
      _logger.e('Check auth state error: $e');
      await _authService.logout();
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _firebaseUser = await _authService.signInWithGoogle();
      
      if (_firebaseUser == null) {
        _errorMessage = 'Sign-in cancelled';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if user exists in backend
      final existingUser = await _authService.getUserByUid(_firebaseUser!.uid);
      
      if (existingUser != null) {
        _currentUser = existingUser;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // User needs to complete registration
      _isLoading = false;
      notifyListeners();
      return false; // Will redirect to registration
    } catch (e) {
      _logger.e('Sign-in Error: $e');
      _errorMessage = 'Failed to sign in. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register new user
  Future<bool> registerUser({
    required String name,
    required String profession,
  }) async {
    if (_firebaseUser == null) {
      _errorMessage = 'No Firebase user found';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.registerUser(
        uid: _firebaseUser!.uid,
        name: name,
        email: _firebaseUser!.email!,
        profession: profession,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Registration Error: $e');
      _errorMessage = 'Failed to register. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      _firebaseUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _logger.e('Logout Error: $e');
      _errorMessage = 'Failed to logout';
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
