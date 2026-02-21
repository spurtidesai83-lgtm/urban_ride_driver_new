import 'package:flutter/foundation.dart';
import '../models/driver_model.dart';
import '../repository/auth_repository.dart';

/// Controller for managing authentication state and business logic
/// Uses ChangeNotifier for state management (can be replaced with Provider, GetX, Riverpod, etc.)
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  DriverModel? _currentDriver;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  DriverModel? get currentDriver => _currentDriver;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentDriver != null;

  /// Send OTP to phone number or email
  Future<bool> sendOtp(String phoneOrEmail) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _authRepository.sendOtp(phoneOrEmail);
      _setLoading(false);
      return success;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Verify OTP code
  Future<bool> verifyOtp(String phoneOrEmail, String otp) async {
    _setLoading(true);
    _clearError();

    try {
      final driver = await _authRepository.verifyOtp(phoneOrEmail, otp);
      _currentDriver = driver;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final driver = await _authRepository.signInWithGoogle();
      _currentDriver = driver;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();

    try {
      final driver = await _authRepository.signInWithApple();
      _currentDriver = driver;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign out current driver
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.signOut();
      _currentDriver = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
