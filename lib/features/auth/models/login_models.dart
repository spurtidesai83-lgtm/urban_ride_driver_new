// Login Request Model
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// Login Response Model
class LoginResponse {
  final String accessToken;
  final String tokenType;
  final String expiresIn;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Backend uses snake_case: access_token, token_type, expires_in
    final token = json['access_token'] ?? json['accessToken'] ?? '';
    final tokenType = json['token_type'] ?? json['tokenType'] ?? 'Bearer';
    
    // expires_in can be int or string from backend
    final expiresInRaw = json['expires_in'] ?? json['expiresIn'] ?? 0;
    final expiresIn = expiresInRaw.toString();
    
    return LoginResponse(
      accessToken: token,
      tokenType: tokenType,
      expiresIn: expiresIn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
    };
  }
}

// Reset Password Request Model
class ResetPasswordRequest {
  final String password;

  ResetPasswordRequest({
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'password': password,
    };
  }
}

// Reset Password Response Model
class ResetPasswordResponse {
  final bool success;
  final String message;

  ResetPasswordResponse({
    required this.success,
    required this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] ?? json['messgae'] ?? '', // Handle typo in spec
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

// Token Validation Response Model
class TokenValidationResponse {
  final bool valid;
  final String? subject; // Driver UUID when token is valid
  final String? error; // Error message when token is invalid/expired

  TokenValidationResponse({
    required this.valid,
    this.subject,
    this.error,
  });

  factory TokenValidationResponse.fromJson(Map<String, dynamic> json) {
    return TokenValidationResponse(
      valid: json['valid'] as bool? ?? false,
      subject: json['subject'] as String?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      if (subject != null) 'subject': subject,
      if (error != null) 'error': error,
    };
  }

  bool get isExpired => error?.contains('expired') ?? false;
}
