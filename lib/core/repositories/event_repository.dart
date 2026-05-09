import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/event.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// EVENT REPOSITORY — §6 Events Endpoints
// ──────────────────────────────────────────────────────────────────────────────

class EventRepository {
  EventRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;
  final Dio _dio;

  // ── GET /events ───────────────────────────────────────────────────────────
  Future<PaginatedResponse<Event>> getEvents({
    int page = 1,
    int limit = 20,
    String? filter, // 'upcoming'
    String? category, // worship, conference, youth, prayer, outreach, fellowship
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (filter != null) params['filter'] = filter;
    if (category != null) params['category'] = category;

    final res =
        await _dio.get(Endpoints.events, queryParameters: params);
    return PaginatedResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => Event.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── GET /events/featured ──────────────────────────────────────────────────
  Future<ApiResponse<List<Event>>> getFeatured() async {
    final res = await _dio.get(Endpoints.eventsFeatured);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((e) => Event.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <Event>[];
      },
    );
  }

  // ── GET /events/my ────────────────────────────────────────────────────────
  Future<ApiResponse<List<Event>>> getMyEvents() async {
    final res = await _dio.get(Endpoints.eventsMy);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((e) => Event.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <Event>[];
      },
    );
  }

  // ── GET /events/:id ──────────────────────────────────────────────────────
  Future<ApiResponse<Event>> getEvent(String id) async {
    final res = await _dio.get(Endpoints.event(id));
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => Event.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── POST /events/:id/register (RSVP) ─────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> registerForEvent(
      String id) async {
    final res = await _dio.post(Endpoints.eventRegister(id));
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  // ── DELETE /events/:id/register (Cancel RSVP) ────────────────────────────
  Future<ApiResponse<void>> unregisterFromEvent(String id) async {
    final res = await _dio.delete(Endpoints.eventRegister(id));
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (_) {},
    );
  }
}
