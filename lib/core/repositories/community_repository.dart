import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/community.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// COMMUNITY REPOSITORY — talks to /groups, /community/* endpoints
// ──────────────────────────────────────────────────────────────────────────────

class CommunityRepository {
  CommunityRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  // ── Groups ────────────────────────────────────────────────────────────────

  Future<PaginatedResponse<ConnectGroup>> getGroupsPaginated({
    int page = 1,
    int limit = 20,
    String? category,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.groups,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (category != null && category != 'ALL') 'category': category,
        },
      );
      return PaginatedResponse<ConnectGroup>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: ConnectGroup.fromJson,
      );
    } on DioException catch (_) {
      return const PaginatedResponse(
        success: false,
        message: 'Failed to load groups',
        data: [],
        meta: PaginationMeta(page: 1, limit: 20, total: 0, totalPages: 0),
      );
    }
  }

  Future<ApiResponse<GroupDetail>> getGroup(String id) async {
    try {
      final res = await _dio.get(Endpoints.group(id));
      return ApiResponse<GroupDetail>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => GroupDetail.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<void>> joinGroup(String id) async {
    try {
      final res = await _dio.post(Endpoints.groupJoin(id));
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<void>> leaveGroup(String id) async {
    try {
      final res = await _dio.delete(Endpoints.groupLeave(id));
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  // ── Announcements ─────────────────────────────────────────────────────────

  Future<PaginatedResponse<Announcement>> getAnnouncements({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.announcements,
        queryParameters: {'page': page, 'limit': limit},
      );
      return PaginatedResponse<Announcement>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: Announcement.fromJson,
      );
    } on DioException catch (_) {
      return const PaginatedResponse(
        success: false,
        message: 'Failed to load announcements',
        data: [],
        meta: PaginationMeta(page: 1, limit: 20, total: 0, totalPages: 0),
      );
    }
  }

  Future<ApiResponse<Announcement>> getAnnouncement(String id) async {
    try {
      final res = await _dio.get(Endpoints.announcement(id));
      return ApiResponse<Announcement>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => Announcement.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<void>> markAnnouncementRead(String id) async {
    try {
      final res = await _dio.post(Endpoints.announcementRead(id));
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  // ── Testimonies ───────────────────────────────────────────────────────────

  Future<PaginatedResponse<Testimony>> getTestimonies({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.testimonies,
        queryParameters: {'page': page, 'limit': limit},
      );
      return PaginatedResponse<Testimony>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: Testimony.fromJson,
      );
    } on DioException catch (_) {
      return const PaginatedResponse(
        success: false,
        message: 'Failed to load testimonies',
        data: [],
        meta: PaginationMeta(page: 1, limit: 20, total: 0, totalPages: 0),
      );
    }
  }

  Future<ApiResponse<void>> submitTestimony({
    required String title,
    required String content,
    bool isAnonymous = false,
  }) async {
    try {
      final res = await _dio.post(Endpoints.testimonies, data: {
        'title': title,
        'content': content,
        'isAnonymous': isAnonymous,
      });
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<void>> reactTestimony(String id, String type) async {
    try {
      final res = await _dio.post(
        Endpoints.testimonyReact(id),
        data: {'type': type},
      );
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  // ── Directory ─────────────────────────────────────────────────────────────

  Future<PaginatedResponse<DirectoryMember>> getDirectory({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.directory,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      return PaginatedResponse<DirectoryMember>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: DirectoryMember.fromJson,
      );
    } on DioException catch (_) {
      return const PaginatedResponse(
        success: false,
        message: 'Failed to load directory',
        data: [],
        meta: PaginationMeta(page: 1, limit: 20, total: 0, totalPages: 0),
      );
    }
  }

  // ── Invite ────────────────────────────────────────────────────────────────

  Future<ApiResponse<InviteInfo>> generateInvite() async {
    try {
      final res = await _dio.post(Endpoints.inviteGenerate);
      return ApiResponse<InviteInfo>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => InviteInfo.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<InviteStats>> getInviteStats() async {
    try {
      final res = await _dio.get(Endpoints.inviteStats);
      return ApiResponse<InviteStats>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => InviteStats.fromJson(d as Map<String, dynamic>),
      );
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
