import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';
import '../../features/auth/models/login_models.dart';

class AuthApiService {
  // Login with email and password
  Future<LoginResponse> login(String email, String password) async {
    try {
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.loginEndpoint));
      final request = LoginRequest(email: email, password: password);
      
      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(),
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(jsonData);

        if (loginResponse.accessToken.trim().isEmpty) {
          throw Exception('Authentication token missing in login response');
        }
        
        // Save token to storage
        await StorageService.saveToken(
          loginResponse.accessToken,
          loginResponse.tokenType,
          loginResponse.expiresIn,
        );
        await StorageService.saveUserEmail(email);
        
        return loginResponse;
      } else {
        // If the server returns an error, show generic "Server error" as requested
        throw Exception('Server error');
      }
    } on SocketException {
      throw Exception('Server error');
    } on TimeoutException {
      throw Exception('Server error');
    } catch (e) {
      throw Exception('Server error');
    }
  }

  // Logout - clear stored token
  Future<void> logout() async {
    await StorageService.clearAll();
  }

  // Reset password (requires authentication)
  Future<ResetPasswordResponse> resetPassword(String newPassword) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.resetPasswordEndpoint));
      final request = ResetPasswordRequest(password: newPassword);
      
      print('🔐 [AuthAPI] POST ${url.toString()}');
      print('🔐 [AuthAPI] Request: ${request.toJson()}');
      
      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.connectTimeout);

      print('🔐 [AuthAPI] Response status: ${response.statusCode}');
      final jsonData = jsonDecode(response.body);
      print('🔐 [AuthAPI] Response body: $jsonData');

      if (response.statusCode == 200) {
        return ResetPasswordResponse.fromJson(jsonData);
      } else {
        throw Exception(jsonData['message'] ?? jsonData['messgae'] ?? 'Password reset failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [AuthAPI] Reset password error: $e');
      throw Exception('Failed to reset password: $e');
    }
  }

  // Validate token
  Future<TokenValidationResponse> validateToken() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        print('⚠️  [AuthAPI] No token found in storage');
        return TokenValidationResponse(valid: false, error: 'No token found');
      }

      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.validateTokenEndpoint));
      
      print('🔍 [AuthAPI] GET ${url.toString()}');
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      print('🔍 [AuthAPI] Token validation response status: ${response.statusCode}');
      final jsonData = jsonDecode(response.body);
      print('🔍 [AuthAPI] Token validation response: $jsonData');

      if (response.statusCode == 200) {
        final validationResponse = TokenValidationResponse.fromJson(jsonData);
        if (validationResponse.valid) {
          print('✅ [AuthAPI] Token is valid, subject: ${validationResponse.subject}');
        } else {
          print('❌ [AuthAPI] Token is invalid: ${validationResponse.error}');
        }
        return validationResponse;
      } else {
        print('❌ [AuthAPI] Token validation failed with status: ${response.statusCode}');
        return TokenValidationResponse(
          valid: false,
          error: jsonData['error'] ?? 'Token validation failed',
        );
      }
    } catch (e) {
      print('❌ [AuthAPI] Token validation error: $e');
      return TokenValidationResponse(
        valid: false,
        error: 'Failed to validate token: $e',
      );
    }
  }
}
