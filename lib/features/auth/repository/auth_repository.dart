import '../models/driver_model.dart';
import '../../../shared/services/auth_api_service.dart';
import '../../../shared/services/storage_service.dart';

/// Repository for handling authentication operations
/// This class abstracts the API calls and business logic for authentication
class AuthRepository {
  final AuthApiService _authApiService = AuthApiService();

  /// Send OTP to phone number or email
  /// Returns true if OTP was sent successfully
  Future<bool> sendOtp(String phoneOrEmail) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Implement actual API call when backend supports OTP
      // Mock implementation for now
      return true;
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  /// Verify OTP code
  /// Returns DriverModel if verification is successful
  Future<DriverModel> verifyOtp(String phoneOrEmail, String otp) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual API call when backend supports OTP
      // Mock implementation for now
      if (otp.length == 6) {
        return DriverModel(
          id: 'driver_${DateTime.now().millisecondsSinceEpoch}',
          phoneNumber: phoneOrEmail.contains('@') ? null : phoneOrEmail,
          email: phoneOrEmail.contains('@') ? phoneOrEmail : null,
          isVerified: true,
          createdAt: DateTime.now(),
        );
      } else {
        throw Exception('Invalid OTP');
      }
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  /// Login with email and password
  /// Returns DriverModel if login is successful
  Future<DriverModel> loginWithEmail(String email, String password) async {
    try {
      // Call the actual backend API
      final loginResponse = await _authApiService.login(email, password);
      
      // Token is already saved in the API service
      // Return a DriverModel with basic info
      return DriverModel(
        id: 'driver_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        fullName: email.split('@')[0], // Will be updated from profile API
        isVerified: true,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      // Don't modify the exception message, let it bubble up
      rethrow;
    }
  }

  /// Send password reset email to backend
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      // TODO: Implement actual API endpoint
      // For now, throw unimplemented error
      throw UnimplementedError('Password reset not yet implemented');
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Sign out current driver
  Future<void> signOut() async {
    try {
      await _authApiService.logout();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      // TODO: Implement change password API call
      throw UnimplementedError('Change password not yet implemented');
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  /// Reset password with new password
  Future<bool> resetPassword(String newPassword) async {
    try {
      // TODO: Implement reset password API call
      throw UnimplementedError('Reset password not yet implemented');
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  /// Validate authentication token
  Future<bool> validateToken() async {
    try {
      // Check if token exists in storage
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      try {
        // Verify token with backend
        final validationResponse = await _authApiService.validateToken();

        if (validationResponse.valid) {
          return true;
        } else {
          await signOut();
          return false;
        }
      } catch (e) {
        // Backend/network issue: keep user logged in if a token exists locally.
        print('⚠️ Token validation API unavailable, using local token fallback: $e');
        return true;
      }
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }

  /// Sign in with Google
  /// Returns DriverModel if sign in is successful
  Future<DriverModel> signInWithGoogle() async {
    try {
      throw UnimplementedError('Google Sign-In is not yet implemented. Use email/password login instead.');
    } catch (e) {
      throw Exception('Google Sign-In not available: $e');
    }
  }

  /// Sign in with Apple
  /// Returns DriverModel if sign in is successful
  Future<DriverModel> signInWithApple() async {
    try {
      throw UnimplementedError('Apple Sign-In is not yet implemented. Use email/password login instead.');
    } catch (e) {
      throw Exception('Apple Sign-In not available: $e');
    }
  }
}
