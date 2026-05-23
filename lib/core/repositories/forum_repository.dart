import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/forum.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// FORUM REPOSITORY — talks to /forum/* endpoints
// ──────────────────────────────────────────────────────────────────────────────

class ForumRepository {
  ForumRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<ApiResponse<List<ForumCategory>>> fetchCategories() async {
    try {
      final res = await _dio.get(Endpoints.forumCategories);
      final raw = res.data as Map<String, dynamic>;
      final list = (raw['data'] as List?) ?? [];
      return ApiResponse<List<ForumCategory>>(
        success: raw['success'] as bool? ?? true,
        message: raw['message'] as String? ?? '',
        data: list
            .asMap()
            .entries
            .map((e) =>
                ForumCategory.fromJson(e.value as Map<String, dynamic>, index: e.key))
            .toList(),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<List<ForumThread>>> fetchTrending() async {
    try {
      final res = await _dio.get(Endpoints.forumTrending);
      final raw = res.data as Map<String, dynamic>;
      final list = (raw['data'] as List?) ?? [];
      return ApiResponse<List<ForumThread>>(
        success: raw['success'] as bool? ?? true,
        message: raw['message'] as String? ?? '',
        data: list
            .map((e) => ForumThread.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<PaginatedResponse<ForumThread>> fetchRecentThreads({
    int page = 1,
    int limit = 20,
    String sort = 'recent',
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.forumRecent,
        queryParameters: {'page': page, 'limit': limit, 'sort': sort},
      );
      return PaginatedResponse<ForumThread>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: ForumThread.fromJson,
      );
    } on DioException catch (_) {
      return const PaginatedResponse(
        success: false,
        message: 'Failed to load threads',
        data: [],
        meta: PaginationMeta(page: 1, limit: 20, total: 0, totalPages: 0),
      );
    }
  }

  Future<PaginatedResponse<ForumThread>> fetchCategoryThreads(
    String categoryId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.forumCategoryThreads(categoryId),
        queryParameters: {'page': page, 'limit': limit},
      );
      return PaginatedResponse<ForumThread>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: ForumThread.fromJson,
      );
    } on DioException catch (_) {
      return const PaginatedResponse(
        success: false,
        message: 'Failed to load threads',
        data: [],
        meta: PaginationMeta(page: 1, limit: 20, total: 0, totalPages: 0),
      );
    }
  }

  Future<ApiResponse<ForumThreadDetail>> fetchThread(
    String id, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.forumThread(id),
        queryParameters: {'page': page, 'limit': limit},
      );
      return ApiResponse<ForumThreadDetail>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) =>
            ForumThreadDetail.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<void>> createThread({
    required String categoryId,
    required String title,
    required String content,
  }) async {
    try {
      final res = await _dio.post(Endpoints.forumThreads, data: {
        'categoryId': categoryId,
        'title': title,
        'content': content,
      });
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<PaginatedResponse<ForumReply>> fetchReplies(
    String threadId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.forumThreadReplies(threadId),
        queryParameters: {'page': page, 'limit': limit},
      );
      return PaginatedResponse<ForumReply>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: ForumReply.fromJson,
      );
    } on DioException catch (_) {
      return const PaginatedResponse(
        success: false,
        message: 'Failed to load replies',
        data: [],
        meta: PaginationMeta(page: 1, limit: 20, total: 0, totalPages: 0),
      );
    }
  }

  Future<ApiResponse<void>> postReply(String threadId, String content) async {
    try {
      final res = await _dio.post(
        Endpoints.forumThreadReplies(threadId),
        data: {'content': content},
      );
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleLike(String threadId) async {
    try {
      final res = await _dio.post(Endpoints.forumThreadLike(threadId));
      return ApiResponse<Map<String, dynamic>>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleBookmark(
      String threadId) async {
    try {
      final res = await _dio.post(Endpoints.forumThreadBookmark(threadId));
      return ApiResponse<Map<String, dynamic>>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleReplyLike(
      String replyId) async {
    try {
      final res = await _dio.post(Endpoints.forumReplyLike(replyId));
      return ApiResponse<Map<String, dynamic>>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
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

// ── Icon/color lookup for categories returned by API ─────────────────────────

IconData forumCategoryIcon(String? slug) {
  switch (slug) {
    case 'prayer':
      return Icons.volunteer_activism_outlined;
    case 'bible-study':
      return Icons.menu_book_outlined;
    case 'testimonies':
      return Icons.stars_outlined;
    case 'youth':
      return Icons.school_outlined;
    case 'events':
      return Icons.event_outlined;
    case 'volunteer':
      return Icons.handshake_outlined;
    case 'qna':
      return Icons.help_outline;
    default:
      return Icons.chat_bubble_outline;
  }
}

Color forumCategoryColor(int index) {
  const colors = [
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF059669),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF0EA5E9),
    Color(0xFF6366F1),
  ];
  return colors[index % colors.length];
}
