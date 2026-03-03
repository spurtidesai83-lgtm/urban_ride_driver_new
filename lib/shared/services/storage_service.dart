import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';
  static const String _userEmailKey = 'user_email';
  static const List<String> _preservedPrefixes = ['pickup_progress_'];
  
  // Save authentication token
  static Future<void> saveToken(String token, String tokenType, String expiresIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_tokenTypeKey, tokenType);
      await prefs.setString(_expiresInKey, expiresIn);
    } catch (e) {
      print('❌ [StorageService] Failed to save token: $e');
      rethrow;
    }
  }
  
  // Get authentication token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token;
    } catch (e) {
      print('❌ [StorageService] Failed to retrieve token: $e');
      return null;
    }
  }
  
  // Get token type
  static Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }
  
  // Save user email
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }
  
  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }
  
  // Clear all stored data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      final shouldPreserve = _preservedPrefixes.any((prefix) => key.startsWith(prefix));
      if (!shouldPreserve) {
        await prefs.remove(key);
      }
    }
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
