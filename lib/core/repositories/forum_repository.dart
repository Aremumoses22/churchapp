import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/forum.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// FORUM REPOSITORY
//
// Covers /forum/* endpoints
// See API_INTEGRATION_GUIDE.md § 13
// ──────────────────────────────────────────────────────────────────────────────

abstract class ForumRepository {
  List<ForumCategory> getCategories();
  List<ForumThread> getTrendingTopics();
  List<ForumThread> getRecentThreads();
  List<ForumThread> getThreadsForCategory(String categoryId);
  ForumCategory? getCategoryMeta(String categoryId);
  ForumPost getPost(String threadId);
  List<ForumReply> getReplies(String threadId);
}

class MockForumRepository implements ForumRepository {
  @override
  List<ForumCategory> getCategories() => const [
        ForumCategory(
          id: 'prayer',
          label: 'Prayer\nRequests',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFFEF4444),
          threadCount: 128,
          description: 'Share and support prayer needs',
        ),
        ForumCategory(
          id: 'bible-study',
          label: 'Bible\nDiscussion',
          icon: Icons.menu_book_outlined,
          color: Color(0xFF3B82F6),
          threadCount: 95,
          description: 'Explore scripture together',
        ),
        ForumCategory(
          id: 'testimonies',
          label: 'Testimonies',
          icon: Icons.stars_outlined,
          color: Color(0xFF8B5CF6),
          threadCount: 64,
          description: 'Share what God has done',
        ),
        ForumCategory(
          id: 'general',
          label: 'General',
          icon: Icons.chat_bubble_outline,
          color: Color(0xFF059669),
          threadCount: 210,
          description: 'Fellowship and conversation',
        ),
        ForumCategory(
          id: 'youth',
          label: 'Youth\nForum',
          icon: Icons.school_outlined,
          color: Color(0xFFF59E0B),
          threadCount: 47,
          description: 'Young adults community',
        ),
        ForumCategory(
          id: 'events',
          label: 'Events &\nMeetups',
          icon: Icons.event_outlined,
          color: Color(0xFFEC4899),
          threadCount: 33,
          description: 'Plan and discuss events',
        ),
        ForumCategory(
          id: 'volunteer',
          label: 'Serve &\nVolunteer',
          icon: Icons.handshake_outlined,
          color: Color(0xFF0EA5E9),
          threadCount: 22,
          description: 'Service opportunities',
        ),
        ForumCategory(
          id: 'qna',
          label: 'Q & A',
          icon: Icons.help_outline,
          color: Color(0xFF6366F1),
          threadCount: 156,
          description: 'Ask questions, get answers',
        ),
      ];

  @override
  List<ForumThread> getTrendingTopics() => const [
        ForumThread(
          id: 't1',
          title: 'Sunday sermon discussion - "Walking by Faith"',
          author: '',
          authorInitials: '',
          avatarColor: Color(0xFF3B82F6),
          body: '',
          replies: 34,
          likes: 0,
          timeAgo: '',
          category: 'Bible Discussion',
          categoryColor: Color(0xFF3B82F6),
        ),
        ForumThread(
          id: 't2',
          title: 'Prayer chain for the Johnson family',
          author: '',
          authorInitials: '',
          avatarColor: Color(0xFFEF4444),
          body: '',
          replies: 52,
          likes: 0,
          timeAgo: '',
          category: 'Prayer Requests',
          categoryColor: Color(0xFFEF4444),
        ),
        ForumThread(
          id: 't3',
          title: 'Volunteers needed for community outreach Sat',
          author: '',
          authorInitials: '',
          avatarColor: Color(0xFF0EA5E9),
          body: '',
          replies: 18,
          likes: 0,
          timeAgo: '',
          category: 'Serve & Volunteer',
          categoryColor: Color(0xFF0EA5E9),
        ),
      ];

  @override
  List<ForumThread> getRecentThreads() => const [
        ForumThread(
          id: 'r1',
          title: 'How has your quiet time changed this year?',
          author: 'Sarah M.',
          authorInitials: 'SM',
          avatarColor: Color(0xFF8B5CF6),
          category: 'General',
          categoryColor: Color(0xFF059669),
          body:
              'I have been using a journaling method for my quiet time and it has completely transformed how I engage with scripture...',
          replies: 12,
          likes: 28,
          timeAgo: '2h ago',
        ),
        ForumThread(
          id: 'r2',
          title: 'Please pray for healing - upcoming surgery',
          author: 'David K.',
          authorInitials: 'DK',
          avatarColor: Color(0xFFEF4444),
          category: 'Prayer Requests',
          categoryColor: Color(0xFFEF4444),
          body:
              'I have surgery scheduled for next Thursday. Would really appreciate the church family covering me in prayer...',
          replies: 31,
          likes: 67,
          timeAgo: '4h ago',
          isPinned: true,
        ),
        ForumThread(
          id: 'r3',
          title: 'Youth camp photos & highlights!',
          author: 'Pastor James',
          authorInitials: 'PJ',
          avatarColor: Color(0xFFF59E0B),
          category: 'Youth Forum',
          categoryColor: Color(0xFFF59E0B),
          body:
              'What an incredible week at summer camp! 23 young people gave their lives to Christ.',
          replies: 19,
          likes: 94,
          timeAgo: '6h ago',
        ),
      ];

  @override
  List<ForumThread> getThreadsForCategory(String categoryId) => [
        ForumThread(
          id: '$categoryId-1',
          title: 'Welcome to this category - read first!',
          author: 'Admin',
          authorInitials: 'AD',
          avatarColor: const Color(0xFF1E40AF),
          body:
              'Welcome! Please read the community guidelines before posting.',
          replies: 8,
          likes: 45,
          timeAgo: '3d ago',
          isPinned: true,
        ),
        ForumThread(
          id: '$categoryId-2',
          title: 'What has been on your heart lately?',
          author: 'Rebecca T.',
          authorInitials: 'RT',
          avatarColor: const Color(0xFF8B5CF6),
          body:
              'I wanted to open a space for us to share what God has been putting on our hearts this season.',
          replies: 23,
          likes: 56,
          timeAgo: '5h ago',
        ),
      ];

  @override
  ForumCategory? getCategoryMeta(String categoryId) {
    try {
      return getCategories().firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  @override
  ForumPost getPost(String threadId) => const ForumPost(
        id: 'mock',
        title: 'Please pray for healing - upcoming surgery',
        author: 'David K.',
        authorInitials: 'DK',
        avatarColor: Color(0xFFEF4444),
        body:
            'Dear church family,\n\nI have surgery scheduled for next Thursday. Please cover me in prayer.\n\n"Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God." - Philippians 4:6',
        category: 'Prayer Requests',
        categoryColor: Color(0xFFEF4444),
        timeAgo: '4 hours ago',
        views: 234,
        likeCount: 67,
      );

  @override
  List<ForumReply> getReplies(String threadId) => const [
        ForumReply(
          id: 'rep1',
          author: 'Sarah M.',
          authorInitials: 'SM',
          avatarColor: Color(0xFF8B5CF6),
          body: 'Praying for you, David! God is in control.',
          timeAgo: '3h ago',
          likes: 12,
        ),
        ForumReply(
          id: 'rep2',
          author: 'Pastor James',
          authorInitials: 'PJ',
          avatarColor: Color(0xFFF59E0B),
          body:
              'Brother David, I will be praying specifically for you and your family this week.',
          timeAgo: '3h ago',
          likes: 24,
        ),
        ForumReply(
          id: 'rep3',
          author: 'Grace L.',
          authorInitials: 'GL',
          avatarColor: Color(0xFF3B82F6),
          body:
              'Isaiah 41:10 — "Fear not, for I am with you." Standing with you in faith!',
          timeAgo: '2h ago',
          likes: 9,
        ),
      ];
}

// ── Real API repository ───────────────────────────────────────────────────────

class ApiForumRepository implements ForumRepository {
  ApiForumRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  // Legacy sync methods not used with real API — return empty
  @override
  List<ForumCategory> getCategories() => [];
  @override
  List<ForumThread> getTrendingTopics() => [];
  @override
  List<ForumThread> getRecentThreads() => [];
  @override
  List<ForumThread> getThreadsForCategory(String categoryId) => [];
  @override
  ForumCategory? getCategoryMeta(String categoryId) => null;
  @override
  ForumPost getPost(String threadId) => const ForumPost(
        title: '',
        author: '',
        authorInitials: '',
        avatarColor: Color(0xFF64748B),
        body: '',
        category: '',
        categoryColor: Color(0xFF64748B),
        timeAgo: '',
        views: 0,
      );
  @override
  List<ForumReply> getReplies(String threadId) => [];

  // ── Async API methods ─────────────────────────────────────────────────────

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

  Future<ApiResponse<ForumPost>> fetchThread(String id) async {
    try {
      final res = await _dio.get(Endpoints.forumThread(id));
      return ApiResponse<ForumPost>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => ForumPost.fromJson(d as Map<String, dynamic>),
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
