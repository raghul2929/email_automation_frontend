import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageHelper {
  static final _secureStorage = const FlutterSecureStorage(
       aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  
  // JWT Token (Secure Storage)
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.keyJwtToken, value: token);
  }
   // ✅ ADD THIS METHOD - Get MongoDB userId
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserId);
  }
  
  // ✅ ADD THIS METHOD - Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserEmail);
  }
  
  // ✅ ADD THIS METHOD - Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserName);
  }
  
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.keyJwtToken);
  }
  
  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.keyJwtToken);
  }
  
  // User Data (Shared Preferences)
  static Future<void> saveUserData({
    required String userId,
    required String email,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserId, userId);
    await prefs.setString(AppConstants.keyUserEmail, email);
    await prefs.setString(AppConstants.keyUserName, name);
  }
  
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(AppConstants.keyUserId),
      'email': prefs.getString(AppConstants.keyUserEmail),
      'name': prefs.getString(AppConstants.keyUserName),
    };
  }
  
  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
