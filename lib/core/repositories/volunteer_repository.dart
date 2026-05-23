import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/volunteer.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// VOLUNTEER REPOSITORY — /volunteer/* endpoints
// ──────────────────────────────────────────────────────────────────────────────

class VolunteerRepository {
  VolunteerRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;
  final Dio _dio;

  Future<List<VolunteerOpportunity>> getOpportunities({
    String? ministry,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.volunteerOpportunities,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (ministry != null && ministry.isNotEmpty) 'ministry': ministry,
        },
      );
      final raw = res.data as Map<String, dynamic>;
      final list = (raw['data'] as List?) ?? [];
      return list
          .map((e) => VolunteerOpportunity.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<ApiResponse<void>> signUp(String opportunityId) async {
    try {
      final res = await _dio.post(Endpoints.volunteerSignup(opportunityId));
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<List<RosterShift>> getRoster() async {
    try {
      final res = await _dio.get(Endpoints.volunteerRoster);
      final raw = res.data as Map<String, dynamic>;
      final list = (raw['data'] as List?) ?? [];
      return list
          .map((e) => RosterShift.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<ApiResponse<void>> checkIn(String shiftId) async {
    try {
      final res = await _dio.post(Endpoints.volunteerCheckin(shiftId));
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
