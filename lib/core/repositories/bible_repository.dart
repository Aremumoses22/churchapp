import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/bible.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BIBLE REPOSITORY — talks to /bible/* endpoints
// ──────────────────────────────────────────────────────────────────────────────

class BibleRepository {
  BibleRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<List<BibleBook>> fetchBooks() async {
    final res = await _dio.get(Endpoints.bibleBooks);
    final raw = res.data as Map<String, dynamic>;
    final list = (raw['data'] as List?) ?? [];
    return list
        .map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BibleChapterData> fetchChapter(String bookId, int chapter) async {
    final res = await _dio.get(Endpoints.bibleChapter(bookId, chapter));
    final raw = res.data as Map<String, dynamic>;
    final data = raw['data'] as Map<String, dynamic>? ?? raw;
    return BibleChapterData.fromJson(data);
  }

  Future<List<BibleVerse>> searchBible(String query, {int limit = 20}) async {
    final res = await _dio.get(
      Endpoints.bibleSearch,
      queryParameters: {'q': query, 'limit': limit},
    );
    final raw = res.data as Map<String, dynamic>;
    final list = (raw['data'] as List?) ?? [];
    return list
        .map((e) => BibleVerse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BibleHighlight>> fetchHighlights() async {
    final res = await _dio.get(Endpoints.bibleHighlights);
    final raw = res.data as Map<String, dynamic>;
    final list = (raw['data'] as List?) ?? [];
    return list
        .map((e) => BibleHighlight.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BibleHighlight?> addHighlight({
    required String verseId,
    String color = 'yellow',
    String? note,
  }) async {
    final res = await _dio.post(
      Endpoints.bibleHighlights,
      data: {
        'verseId': verseId,
        'color': color,
        if (note != null) 'note': note,
      },
    );
    final raw = res.data as Map<String, dynamic>;
    final data = raw['data'] as Map<String, dynamic>?;
    return data != null ? BibleHighlight.fromJson(data) : null;
  }

  Future<void> deleteHighlight(String id) async {
    await _dio.delete(Endpoints.bibleHighlight(id));
  }

  Future<Devotional?> fetchTodayDevotional() async {
    final res = await _dio.get(Endpoints.devotionalsToday);
    final raw = res.data as Map<String, dynamic>;
    final data = raw['data'] as Map<String, dynamic>?;
    if (data != null) return Devotional.fromJson(data);
    return null;
  }

  Future<DevotionalStreak?> fetchStreak() async {
    final res = await _dio.get(Endpoints.devotionalsStreak);
    final raw = res.data as Map<String, dynamic>;
    final data = raw['data'] as Map<String, dynamic>?;
    if (data != null) return DevotionalStreak.fromJson(data);
    return null;
  }

  Future<void> markDevotionalRead(String id) async {
    await _dio.post(Endpoints.devotionalRead(id));
  }

  Future<List<ReadingPlan>> fetchReadingPlans() async {
    final res = await _dio.get(Endpoints.readingPlans);
    final raw = res.data as Map<String, dynamic>;
    final list = (raw['data'] as List?) ?? [];
    return list
        .map((e) => ReadingPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserReadingPlan>> fetchMyReadingPlans() async {
    final res = await _dio.get(Endpoints.myReadingPlans);
    final raw = res.data as Map<String, dynamic>;
    final list = (raw['data'] as List?) ?? [];
    return list
        .map((e) => UserReadingPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> enrollInPlan(String id) async {
    await _dio.post(Endpoints.readingPlanEnroll(id));
  }

  Future<void> markDayComplete(String planId, int dayNumber) async {
    await _dio.post(
      Endpoints.readingPlanProgress(planId),
      data: {'dayNumber': dayNumber},
    );
  }
}
