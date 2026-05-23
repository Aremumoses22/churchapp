import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/notification.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// NOTIFICATION REPOSITORY — talks to /notifications/* endpoints
// ──────────────────────────────────────────────────────────────────────────────

class NotificationRepository {
  NotificationRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  static const List<String> filterLabels = [
    'All', 'Unread', 'Events', 'Sermons', 'Prayer', 'Giving',
  ];
  static const List<String> groupOrder = [
    'Today', 'Yesterday', 'This Week', 'Earlier',
  ];

  Future<PaginatedResponse<AppNotification>> getNotifications({
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.notifications,
        queryParameters: {'page': page, 'limit': limit},
      );
      return PaginatedResponse<AppNotification>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: AppNotification.fromJson,
      );
    } on DioException catch (_) {
      return const PaginatedResponse(
        success: false,
        message: 'Failed to load notifications',
        data: [],
        meta: PaginationMeta(page: 1, limit: 30, total: 0, totalPages: 0),
      );
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get(Endpoints.notificationsUnreadCount);
      final raw = res.data as Map<String, dynamic>;
      final data = raw['data'] as Map<String, dynamic>? ?? {};
      return data['count'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<ApiResponse<void>> markAsRead(String id) async {
    try {
      final res = await _dio.put(Endpoints.notificationRead(id));
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<void>> markAllRead() async {
    try {
      final res = await _dio.put(Endpoints.notificationsReadAll);
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<void>> deleteNotification(String id) async {
    try {
      final res = await _dio.delete(Endpoints.notificationDelete(id));
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  ApiResponse<T> _err<T>(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) return ApiResponse<T>.fromJson(data);
    return ApiResponse<T>(
      success: false,
      message: e.message ?? 'An error occurred',
    );
  }
}
