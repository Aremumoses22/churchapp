import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/sermon.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SERMON REPOSITORY — §5 Sermons Endpoints
// ──────────────────────────────────────────────────────────────────────────────

class SermonRepository {
  SermonRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;
  final Dio _dio;

  // ── GET /sermons ──────────────────────────────────────────────────────────
  Future<PaginatedResponse<Sermon>> getSermons({
    int page = 1,
    int limit = 20,
    String? seriesId,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (seriesId != null) params['seriesId'] = seriesId;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final res =
        await _dio.get(Endpoints.sermons, queryParameters: params);
    return PaginatedResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => Sermon.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── GET /sermons/featured ─────────────────────────────────────────────────
  Future<ApiResponse<List<Sermon>>> getFeatured() async {
    final res = await _dio.get(Endpoints.sermonsFeatured);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((e) => Sermon.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <Sermon>[];
      },
    );
  }

  // ── GET /sermons/saved ────────────────────────────────────────────────────
  Future<ApiResponse<List<Sermon>>> getSaved() async {
    final res = await _dio.get(Endpoints.sermonsSaved);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((e) => Sermon.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <Sermon>[];
      },
    );
  }

  // ── GET /sermons/:id ─────────────────────────────────────────────────────
  Future<ApiResponse<Sermon>> getSermon(String id) async {
    final res = await _dio.get(Endpoints.sermon(id));
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => Sermon.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── GET /sermons/:id/stream ───────────────────────────────────────────────
  Future<ApiResponse<SermonStreamInfo>> getStreamUrl(String id) async {
    final res = await _dio.get(Endpoints.sermonStream(id));
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => SermonStreamInfo.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── POST /sermons/:id/progress ────────────────────────────────────────────
  Future<ApiResponse<void>> saveProgress({
    required String sermonId,
    required int position, // seconds
    bool completed = false,
  }) async {
    final res = await _dio.post(
      Endpoints.sermonProgress(sermonId),
      data: {'position': position, 'completed': completed},
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (_) {},
    );
  }

  // ── POST /sermons/:id/save (toggle bookmark) ─────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> toggleSave(String id) async {
    final res = await _dio.post(Endpoints.sermonSave(id));
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  // ── GET /sermons/:id/notes ────────────────────────────────────────────────
  Future<ApiResponse<SermonNote?>> getNotes(String sermonId) async {
    final res = await _dio.get(Endpoints.sermonNotes(sermonId));
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => json != null
          ? SermonNote.fromJson(json as Map<String, dynamic>)
          : null,
    );
  }

  // ── PUT /sermons/:id/notes ────────────────────────────────────────────────
  Future<ApiResponse<SermonNote>> saveNotes({
    required String sermonId,
    required String content,
  }) async {
    final res = await _dio.put(
      Endpoints.sermonNotes(sermonId),
      data: {'content': content},
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => SermonNote.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── GET /sermons/series/all ───────────────────────────────────────────────
  Future<ApiResponse<List<SermonSeries>>> getAllSeries() async {
    final res = await _dio.get(Endpoints.sermonSeriesAll);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((e) =>
                  SermonSeries.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <SermonSeries>[];
      },
    );
  }

  // ── GET /sermons/series/:id ───────────────────────────────────────────────
  Future<ApiResponse<SermonSeries>> getSeries(String id) async {
    final res = await _dio.get(Endpoints.sermonSeries(id));
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => SermonSeries.fromJson(json as Map<String, dynamic>),
    );
  }
}
