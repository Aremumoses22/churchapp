import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// USER REPOSITORY — §4 User Endpoints
//
// All routes require Bearer token (auto-attached by ApiClient interceptor).
// ──────────────────────────────────────────────────────────────────────────────

class UserRepository {
  UserRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;
  final Dio _dio;

  // ── GET /users/me ─────────────────────────────────────────────────────────
  Future<ApiResponse<UserProfile>> getProfile() async {
    final res = await _dio.get(Endpoints.userProfile);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── PUT /users/me ─────────────────────────────────────────────────────────
  Future<ApiResponse<UserProfile>> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? department,
    bool? isDirectoryVisible,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (bio != null) body['bio'] = bio;
    if (department != null) body['department'] = department;
    if (isDirectoryVisible != null) {
      body['isDirectoryVisible'] = isDirectoryVisible;
    }
    final res = await _dio.put(Endpoints.userProfile, data: body);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── PUT /users/me/avatar ──────────────────────────────────────────────────
  Future<ApiResponse<UserProfile>> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.put(Endpoints.userAvatar, data: formData);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── PUT /users/me/notification-prefs ──────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> updateNotificationPrefs(
      Map<String, bool> prefs) async {
    final res = await _dio.put(Endpoints.notificationPrefs, data: prefs);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  // ── PUT /users/me/fcm-token ───────────────────────────────────────────────
  Future<ApiResponse<void>> registerFcmToken(String token) async {
    final res =
        await _dio.put(Endpoints.fcmToken, data: {'token': token});
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (_) {},
    );
  }

  // ── GET /users/me/attendance ──────────────────────────────────────────────
  Future<ApiResponse<AttendanceData>> getAttendance() async {
    final res = await _dio.get(Endpoints.attendance);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => AttendanceData.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── GET /users/me/milestones ──────────────────────────────────────────────
  Future<ApiResponse<List<Milestone>>> getMilestones() async {
    final res = await _dio.get(Endpoints.milestones);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <Milestone>[];
      },
    );
  }

  // ── GET /users/me/saved-items ─────────────────────────────────────────────
  Future<ApiResponse<List<SavedItem>>> getSavedItems() async {
    final res = await _dio.get(Endpoints.savedItems);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((e) => SavedItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <SavedItem>[];
      },
    );
  }

  // ── POST /users/me/saved-items ────────────────────────────────────────────
  Future<ApiResponse<SavedItem>> saveItem({
    required String entityType,
    required String entityId,
  }) async {
    final res = await _dio.post(
      Endpoints.savedItems,
      data: {'entityType': entityType, 'entityId': entityId},
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (json) => SavedItem.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── DELETE /users/me/saved-items/:id ──────────────────────────────────────
  Future<ApiResponse<void>> removeSavedItem(String id) async {
    final res = await _dio.delete(Endpoints.savedItem(id));
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      fromJsonT: (_) {},
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// SUPPORTING MODELS
// ──────────────────────────────────────────────────────────────────────────────

class AttendanceData {
  const AttendanceData({
    this.streak = 0,
    this.totalAttendances = 0,
    this.history = const [],
  });

  final int streak;
  final int totalAttendances;
  final List<AttendanceRecord> history;

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      streak: json['streak'] as int? ?? 0,
      totalAttendances: json['totalAttendances'] as int? ?? 0,
      history: (json['history'] as List<dynamic>?)
              ?.map(
                  (e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class AttendanceRecord {
  const AttendanceRecord({required this.date, this.serviceName});
  final String date;
  final String? serviceName;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: json['date'] as String? ?? '',
      serviceName: json['serviceName'] as String?,
    );
  }
}

class Milestone {
  const Milestone({
    required this.id,
    required this.title,
    this.description,
    this.achievedAt,
    this.icon,
  });

  final String id;
  final String title;
  final String? description;
  final String? achievedAt;
  final String? icon;

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      achievedAt: json['achievedAt'] as String?,
      icon: json['icon'] as String?,
    );
  }
}

class SavedItem {
  const SavedItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    this.createdAt,
    this.entity,
  });

  final String id;
  final String entityType; // SERMON, EVENT, DEVOTIONAL, READING_PLAN
  final String entityId;
  final String? createdAt;
  final Map<String, dynamic>? entity; // populated by backend includes

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['id'] as String,
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
      entity: json['entity'] as Map<String, dynamic>?,
    );
  }
}
