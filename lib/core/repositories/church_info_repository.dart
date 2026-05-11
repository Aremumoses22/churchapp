import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/church_info.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CHURCH INFO REPOSITORY
//
// Covers GET /church/about, /church/staff, /church/campuses,
//         /church/faqs, POST /church/contact
// See API_INTEGRATION_GUIDE.md § 8
// ──────────────────────────────────────────────────────────────────────────────

abstract class ChurchInfoRepository {
  Future<ApiResponse<ChurchInfo>> getAbout();
  Future<ApiResponse<List<StaffMember>>> getStaff();
  Future<ApiResponse<List<Campus>>> getCampuses();
  Future<ApiResponse<List<ChurchFaq>>> getFaqs();
  Future<ApiResponse<void>> sendContact(String subject, String message);
}

class ApiChurchInfoRepository implements ChurchInfoRepository {
  ApiChurchInfoRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  @override
  Future<ApiResponse<ChurchInfo>> getAbout() async {
    try {
      final res = await _dio.get(Endpoints.churchAbout);
      return ApiResponse<ChurchInfo>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => ChurchInfo.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  @override
  Future<ApiResponse<List<StaffMember>>> getStaff() async {
    try {
      final res = await _dio.get(Endpoints.churchStaff);
      final data = res.data as Map<String, dynamic>;
      final list = (data['data'] as List?) ?? [];
      return ApiResponse<List<StaffMember>>(
        success: data['success'] as bool? ?? true,
        message: data['message'] as String? ?? '',
        data: list
            .map((e) => StaffMember.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  @override
  Future<ApiResponse<List<Campus>>> getCampuses() async {
    try {
      final res = await _dio.get(Endpoints.churchCampuses);
      final data = res.data as Map<String, dynamic>;
      final list = (data['data'] as List?) ?? [];
      return ApiResponse<List<Campus>>(
        success: data['success'] as bool? ?? true,
        message: data['message'] as String? ?? '',
        data: list
            .map((e) => Campus.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  @override
  Future<ApiResponse<List<ChurchFaq>>> getFaqs() async {
    try {
      final res = await _dio.get(Endpoints.churchFaqs);
      final data = res.data as Map<String, dynamic>;
      final list = (data['data'] as List?) ?? [];
      return ApiResponse<List<ChurchFaq>>(
        success: data['success'] as bool? ?? true,
        message: data['message'] as String? ?? '',
        data: list
            .map((e) => ChurchFaq.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  @override
  Future<ApiResponse<void>> sendContact(
      String subject, String message) async {
    try {
      final res = await _dio.post(
        Endpoints.churchContact,
        data: {'subject': subject, 'message': message},
      );
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
