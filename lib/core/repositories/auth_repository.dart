import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/auth.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/token_storage.dart';

// ──────────────────────────────────────────────────────────────────────────────
// AUTH REPOSITORY
//
// Talks to the backend auth endpoints and manages token persistence.
// Every method returns an ApiResponse so the UI layer can check success/errors.
//
// See API_INTEGRATION_GUIDE.md § 3 — Auth Endpoints.
// ──────────────────────────────────────────────────────────────────────────────

class AuthRepository {
  AuthRepository({
    Dio? dio,
    TokenStorage? tokenStorage,
  })  : _dio = dio ?? ApiClient.instance.dio,
        _tokenStorage = tokenStorage ?? TokenStorage.instance;

  final Dio _dio;
  final TokenStorage _tokenStorage;

  // ── POST /auth/register ────────────────────────────────────────────────
  /// Register a new user. Returns success message (verification email sent).
  Future<ApiResponse<void>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        Endpoints.register,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── POST /auth/login ──────────────────────────────────────────────────
  /// Login and receive JWT token pair + user profile.
  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        Endpoints.login,
        data: request.toJson(),
      );
      final apiResponse = ApiResponse<LoginResponse>.fromJson(
        response.data,
        fromJsonT: (data) =>
            LoginResponse.fromJson(data as Map<String, dynamic>),
      );

      // Persist tokens on successful login.
      if (apiResponse.success && apiResponse.data != null) {
        await _tokenStorage.saveTokens(
          accessToken: apiResponse.data!.accessToken,
          refreshToken: apiResponse.data!.refreshToken,
        );
      }

      return apiResponse;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── GET /auth/verify-email/:token ─────────────────────────────────────
  /// Verify email using the token from the verification email.
  Future<ApiResponse<void>> verifyEmail(String token) async {
    try {
      final response = await _dio.get('${Endpoints.verifyEmail}/$token');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── POST /auth/resend-verification ────────────────────────────────────
  /// Resend the email verification email.
  Future<ApiResponse<void>> resendVerification(String email) async {
    try {
      final response = await _dio.post(
        Endpoints.resendVerification,
        data: ResendVerificationRequest(email: email).toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── POST /auth/forgot-password ────────────────────────────────────────
  /// Request a password reset email.
  Future<ApiResponse<void>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        Endpoints.forgotPassword,
        data: ForgotPasswordRequest(email: email).toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── POST /auth/reset-password ─────────────────────────────────────────
  /// Reset password using the token from the reset email.
  Future<ApiResponse<void>> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _dio.post(
        Endpoints.resetPassword,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── POST /auth/refresh-token ──────────────────────────────────────────
  /// Get a new access/refresh token pair.
  Future<ApiResponse<AuthTokens>> refreshToken() async {
    try {
      final currentRefresh = await _tokenStorage.getRefreshToken();
      if (currentRefresh == null) {
        return const ApiResponse(
          success: false,
          message: 'No refresh token available',
        );
      }

      final response = await _dio.post(
        Endpoints.refreshToken,
        data: {'refreshToken': currentRefresh},
      );

      final apiResponse = ApiResponse<AuthTokens>.fromJson(
        response.data,
        fromJsonT: (data) =>
            AuthTokens.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        await _tokenStorage.saveTokens(
          accessToken: apiResponse.data!.accessToken,
          refreshToken: apiResponse.data!.refreshToken,
        );
      }

      return apiResponse;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── POST /auth/verify-church-code ─────────────────────────────────────
  /// Join a church by entering the church's unique code.
  Future<ApiResponse<void>> verifyChurchCode(String code) async {
    try {
      final response = await _dio.post(
        Endpoints.verifyChurchCode,
        data: VerifyChurchCodeRequest(code: code).toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── POST /auth/complete-setup ─────────────────────────────────────────
  /// Complete account setup (name, bio, department).
  Future<ApiResponse<void>> completeSetup(CompleteSetupRequest request) async {
    try {
      final response = await _dio.post(
        Endpoints.completeSetup,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── POST /auth/logout ─────────────────────────────────────────────────
  /// Logout and clear tokens.
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _dio.post(Endpoints.logout);
      await _tokenStorage.clearTokens();
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Clear tokens even if server request fails.
      await _tokenStorage.clearTokens();
      return _handleError(e);
    }
  }

  // ── DELETE /auth/account ──────────────────────────────────────────────
  /// Permanently delete user account.
  Future<ApiResponse<void>> deleteAccount() async {
    try {
      final response = await _dio.delete(Endpoints.deleteAccount);
      await _tokenStorage.clearTokens();
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── GET /users/me ─────────────────────────────────────────────────────
  /// Fetch the current user's profile.
  Future<ApiResponse<UserProfile>> getProfile() async {
    try {
      final response = await _dio.get(Endpoints.userProfile);
      return ApiResponse<UserProfile>.fromJson(
        response.data,
        fromJsonT: (data) =>
            UserProfile.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── Check stored tokens ───────────────────────────────────────────────
  /// Returns true if we have valid tokens stored.
  Future<bool> hasStoredTokens() => _tokenStorage.hasTokens();

  // ── Error handler ─────────────────────────────────────────────────────

  ApiResponse<T> _handleError<T>(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      return ApiResponse<T>.fromJson(data);
    }

    // Network / timeout errors.
    String message;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        message = 'Unable to connect to server. Check your internet connection.';
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
      default:
        message = e.message ?? 'An unexpected error occurred.';
    }

    return ApiResponse<T>(success: false, message: message);
  }
}
