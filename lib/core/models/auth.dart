// ──────────────────────────────────────────────────────────────────────────────
// AUTH MODELS
//
// Request / response models for all auth endpoints.
// See API_INTEGRATION_GUIDE.md § 3 — Auth Endpoints.
// ──────────────────────────────────────────────────────────────────────────────

import 'user.dart';

// ── Token Pair ──────────────────────────────────────────────────────────────

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

// ── Login Response ──────────────────────────────────────────────────────────

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserProfile user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

// ── Request DTOs ────────────────────────────────────────────────────────────

class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };
}

class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class ForgotPasswordRequest {
  const ForgotPasswordRequest({required this.email});
  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.token,
    required this.password,
  });

  final String token;
  final String password;

  Map<String, dynamic> toJson() => {
        'token': token,
        'password': password,
      };
}

class VerifyChurchCodeRequest {
  const VerifyChurchCodeRequest({required this.code});
  final String code;

  Map<String, dynamic> toJson() => {'code': code};
}

class CompleteSetupRequest {
  const CompleteSetupRequest({
    required this.name,
    this.bio,
    this.department,
  });

  final String name;
  final String? bio;
  final String? department;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (bio != null) 'bio': bio,
        if (department != null) 'department': department,
      };
}

class ResendVerificationRequest {
  const ResendVerificationRequest({required this.email});
  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}
