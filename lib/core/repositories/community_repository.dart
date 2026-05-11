import 'dart:ui';

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/community.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// COMMUNITY REPOSITORY
//
// Covers /groups, /community/announcements, /community/testimonies,
//         /community/directory, /community/invite
// See API_INTEGRATION_GUIDE.md §§ 11, 12
// ──────────────────────────────────────────────────────────────────────────────

abstract class CommunityRepository {
  // Legacy mock helpers
  List<ConnectGroup> getGroups();
  List<String> getCategories();
}

class MockCommunityRepository implements CommunityRepository {
  @override
  List<String> getCategories() => const [
        'All', 'Men', 'Women', 'Youth', 'Couples',
        'Bible Study', 'Prayer', 'Service',
      ];

  @override
  List<ConnectGroup> getGroups() => const [
        ConnectGroup(
          id: '1',
          name: "Men's Fellowship",
          description:
              'A brotherhood of men pursuing faith, accountability, and purpose together.',
          category: 'MEN',
          memberCount: 24,
          maxMembers: 30,
          meetingDay: 'Saturdays',
          meetingTime: '8:00 AM',
          location: 'Room 201',
          leader: 'Marcus Johnson',
          color: Color(0xFF1E40AF),
          isOpen: true,
        ),
        ConnectGroup(
          id: '2',
          name: "Women's Bible Study",
          description:
              'Diving deep into Scripture together, growing in faith and fellowship.',
          category: 'WOMEN',
          memberCount: 18,
          maxMembers: 20,
          meetingDay: 'Tuesdays',
          meetingTime: '10:00 AM',
          location: 'Chapel',
          leader: 'Rachel Adams',
          color: Color(0xFF7C3AED),
          isOpen: true,
        ),
        ConnectGroup(
          id: '3',
          name: 'Youth Impact',
          description:
              'High-energy gatherings for teens with worship, games, and real talk about faith.',
          category: 'YOUTH',
          memberCount: 35,
          maxMembers: 50,
          meetingDay: 'Fridays',
          meetingTime: '7:00 PM',
          location: 'Youth Center',
          leader: 'Jake Torres',
          color: Color(0xFFEA580C),
          isOpen: true,
        ),
        ConnectGroup(
          id: '4',
          name: 'Couples Connect',
          description:
              'Strengthen your marriage through shared devotion, conversation, and community.',
          category: 'COUPLES',
          memberCount: 12,
          maxMembers: 14,
          meetingDay: 'Wednesdays',
          meetingTime: '7:00 PM',
          location: 'Room 105',
          leader: 'David & Sarah Kim',
          color: Color(0xFFDC2626),
          isOpen: true,
        ),
        ConnectGroup(
          id: '5',
          name: 'Gospel of John Study',
          description:
              'A verse-by-verse journey through the Gospel of John over 12 weeks.',
          category: 'BIBLE_STUDY',
          memberCount: 15,
          maxMembers: 15,
          meetingDay: 'Thursdays',
          meetingTime: '6:30 PM',
          location: 'Library',
          leader: 'Pastor Stephen Cole',
          color: Color(0xFF059669),
          isOpen: false,
        ),
        ConnectGroup(
          id: '6',
          name: 'Intercessory Prayer',
          description:
              'A dedicated group of prayer warriors lifting up the church and community.',
          category: 'PRAYER',
          memberCount: 10,
          maxMembers: 20,
          meetingDay: 'Mondays',
          meetingTime: '6:00 AM',
          location: 'Prayer Room',
          leader: 'Grace Okafor',
          color: Color(0xFF0891B2),
          isOpen: true,
        ),
        ConnectGroup(
          id: '7',
          name: 'Community Outreach',
          description:
              'Serving our local community through food drives, tutoring, and neighborhood projects.',
          category: 'SERVICE',
          memberCount: 28,
          maxMembers: 40,
          meetingDay: 'Saturdays',
          meetingTime: '9:00 AM',
          location: 'Fellowship Hall',
          leader: 'Tom Bradley',
          color: Color(0xFFB45309),
          isOpen: true,
        ),
      ];
}

// ── Real API repository ───────────────────────────────────────────────────────

class ApiCommunityRepository implements CommunityRepository {
  ApiCommunityRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  // Legacy helpers — unused when API providers are active
  @override
  List<String> getCategories() => [];
  @override
  List<ConnectGroup> getGroups() => [];

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
