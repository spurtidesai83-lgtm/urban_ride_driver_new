import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/driver_model.dart';
import '../repository/auth_repository.dart';

class AuthState {
  final DriverModel? currentDriver;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.currentDriver,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    Object? currentDriver = _sentinel,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return AuthState(
      currentDriver: currentDriver == _sentinel ? this.currentDriver : (currentDriver as DriverModel?),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel ? this.errorMessage : (errorMessage as String?),
    );
  }

  static const _sentinel = Object();
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState());

  Future<bool> sendOtp(String phoneOrEmail) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _authRepository.sendOtp(phoneOrEmail);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String phoneOrEmail, String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final driver = await _authRepository.verifyOtp(phoneOrEmail, otp);
      state = state.copyWith(isLoading: false, currentDriver: driver);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final driver = await _authRepository.loginWithEmail(email, password);
      state = state.copyWith(isLoading: false, currentDriver: driver);
      return true;
    } catch (e) {
      // Remove redundant "Exception: " prefix for cleaner UI
      final cleanError = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: cleanError);
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _authRepository.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final driver = await _authRepository.signInWithGoogle();
      state = state.copyWith(isLoading: false, currentDriver: driver);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final driver = await _authRepository.signInWithApple();
      state = state.copyWith(isLoading: false, currentDriver: driver);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepository.signOut();
      state = state.copyWith(isLoading: false, currentDriver: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
     state = state.copyWith(isLoading: true, errorMessage: null);
     try {
       final success = await _authRepository.changePassword(currentPassword, newPassword);
       state = state.copyWith(isLoading: false);
       return success;
     } catch (e) {
       state = state.copyWith(isLoading: false, errorMessage: e.toString());
       return false;
     }
  }

  Future<bool> resetPassword(String newPassword) async {
     state = state.copyWith(isLoading: true, errorMessage: null);
     try {
       print('🔐 [AuthProvider] Calling resetPassword with new password');
       final success = await _authRepository.resetPassword(newPassword);
       state = state.copyWith(isLoading: false);
       print('✅ [AuthProvider] Password reset successful: $success');
       return success;
     } catch (e) {
       print('❌ [AuthProvider] Password reset failed: $e');
       state = state.copyWith(isLoading: false, errorMessage: e.toString());
       return false;
     }
  }

  Future<bool> validateToken() async {
     print('🔍 [AuthProvider] Validating stored token...');
     try {
       final isValid = await _authRepository.validateToken();
       
       if (isValid) {
         print('✅ [AuthProvider] Token is valid, user is authenticated');
         // Token is valid, we can consider user as logged in
         // Update state to reflect authenticated status if needed
         return true;
       } else {
         print('❌ [AuthProvider] Token is invalid, clearing auth state');
         state = state.copyWith(currentDriver: null);
         return false;
       }
     } catch (e) {
       print('❌ [AuthProvider] Token validation error: $e');
       state = state.copyWith(currentDriver: null);
       return false;
     }
  }
}

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
