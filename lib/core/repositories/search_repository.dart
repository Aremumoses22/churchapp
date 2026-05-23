import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/search.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SEARCH REPOSITORY — talks to /search endpoints
// ──────────────────────────────────────────────────────────────────────────────

class SearchRepository {
  SearchRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<List<SearchItem>> search(String query) async {
    try {
      final res = await _dio.get(
        Endpoints.search,
        queryParameters: {'q': query},
      );
      final raw = res.data as Map<String, dynamic>;
      final data = raw['data'] as Map<String, dynamic>? ?? {};
      final results = data['results'] as List<dynamic>? ?? [];
      return results
          .whereType<Map<String, dynamic>>()
          .map(SearchItem.fromJson)
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<List<String>> getTrending() async {
    try {
      final res = await _dio.get(Endpoints.searchTrending);
      final raw = res.data as Map<String, dynamic>;
      final data = raw['data'];
      if (data is List) {
        return data.whereType<String>().toList();
      }
      if (data is Map<String, dynamic>) {
        final list = data['trending'] as List<dynamic>? ?? [];
        return list.whereType<String>().toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }
}
