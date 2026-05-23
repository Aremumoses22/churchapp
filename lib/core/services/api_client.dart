// ──────────────────────────────────────────────────────────────────────────────
// API CLIENT
//
// Singleton Dio instance with:
//   • Base URL from ApiConfig
//   • Auth interceptor (auto-attaches Bearer token)
//   • Token refresh interceptor (auto-refreshes on 401)
//   • Request/response logging in debug mode
// ──────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_tokenStorage, _dio),
      if (kDebugMode) _LogInterceptor(),
    ]);
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage.instance;

  Dio get dio => _dio;
}

// ──────────────────────────────────────────────────────────────────────────────
// Auth Interceptor — attaches Bearer token & handles 401 refresh
// ──────────────────────────────────────────────────────────────────────────────

class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor(this._tokenStorage, this._dio);

  final TokenStorage _tokenStorage;
  final Dio _dio;
  bool _isRefreshing = false;

  /// Paths that should never carry a token.
  static const _publicPaths = [
    Endpoints.login,
    Endpoints.register,
    Endpoints.forgotPassword,
    Endpoints.resetPassword,
    Endpoints.resendVerification,
    Endpoints.refreshToken,
  ];

  bool _isPublic(String path) =>
      _publicPaths.any((p) => path.contains(p)) ||
      path.contains('/auth/verify-email/');

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options.path)) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isPublic(err.requestOptions.path)) {
      // Try refreshing the token.
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final refreshToken = await _tokenStorage.getRefreshToken();
          if (refreshToken == null) {
            _isRefreshing = false;
            return handler.next(err);
          }

          final response = await _dio.post(
            Endpoints.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          final data = response.data['data'];
          await _tokenStorage.saveTokens(
            accessToken: data['accessToken'],
            refreshToken: data['refreshToken'],
          );

          _isRefreshing = false;

          // Retry the original request with the new token.
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] =
              'Bearer ${data['accessToken']}';

          final retryResponse = await _dio.fetch(retryOptions);
          return handler.resolve(retryResponse);
        } on DioException {
          _isRefreshing = false;
          // Refresh failed — clear tokens, user must re-login.
          await _tokenStorage.clearTokens();
          return handler.next(err);
        }
      }
    }
    handler.next(err);
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Simple debug logger
// ──────────────────────────────────────────────────────────────────────────────

class _LogInterceptor extends Interceptor {
  static const _maxBodyLen = 500;

  String _truncate(Object? body) {
    if (body == null) return 'null';
    final str = body.toString();
    return str.length > _maxBodyLen ? '${str.substring(0, _maxBodyLen)}…' : str;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri}');
    if (options.data != null) {
      debugPrint('  body: ${_truncate(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('  body: ${_truncate(response.data)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('✖ ${err.response?.statusCode} ${err.requestOptions.uri}');
    if (err.response?.data != null) {
      debugPrint('  error: ${_truncate(err.response!.data)}');
    }
    handler.next(err);
  }
}
