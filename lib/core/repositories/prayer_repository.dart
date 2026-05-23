import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/prayer.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PRAYER REPOSITORY — /prayer-requests endpoints
// ──────────────────────────────────────────────────────────────────────────────

class PrayerRepository {
  PrayerRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;
  final Dio _dio;

  Future<ApiResponse<List<PrayerRequest>>> getMyRequests() async {
    try {
      final res = await _dio.get(Endpoints.myPrayerRequests);
      return ApiResponse<List<PrayerRequest>>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) {
          if (d is List) {
            return d
                .map((e) => PrayerRequest.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <PrayerRequest>[];
        },
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<PrayerRequest>> submitRequest({
    required String title,
    String? content,
    bool isAnonymous = false,
    bool isUrgent = false,
  }) async {
    try {
      final res = await _dio.post(
        Endpoints.prayerRequests,
        data: {
          'title': title,
          'content': content ?? '',
          'isAnonymous': isAnonymous,
          'isUrgent': isUrgent,
        },
      );
      return ApiResponse<PrayerRequest>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => PrayerRequest.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<void>> prayForRequest(String id) async {
    try {
      final res = await _dio.post(Endpoints.prayerRequestPray(id));
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
