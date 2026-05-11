import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/home_feed.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// HOME FEED REPOSITORY
//
// Covers GET /home/feed
// See API_INTEGRATION_GUIDE.md § 9
// ──────────────────────────────────────────────────────────────────────────────

abstract class HomeFeedRepository {
  Future<ApiResponse<HomeFeed>> getFeed();
}

class ApiHomeFeedRepository implements HomeFeedRepository {
  ApiHomeFeedRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  @override
  Future<ApiResponse<HomeFeed>> getFeed() async {
    try {
      final res = await _dio.get(Endpoints.homeFeed);
      return ApiResponse<HomeFeed>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => HomeFeed.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) return ApiResponse<HomeFeed>.fromJson(data);
      return ApiResponse<HomeFeed>(
        success: false,
        message: e.message ?? 'An error occurred',
      );
    }
  }
}
