import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/media.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// MEDIA REPOSITORY — /media/* endpoints
// ──────────────────────────────────────────────────────────────────────────────

class MediaRepository {
  MediaRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;
  final Dio _dio;

  // ── Podcasts ──────────────────────────────────────────────────────────────

  Future<List<PodcastEpisode>> getPodcasts({int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.get(
        Endpoints.mediaPodcasts,
        queryParameters: {'page': page, 'limit': limit},
      );
      final raw = res.data as Map<String, dynamic>;
      final list = (raw['data'] as List?) ?? [];
      return list
          .map((e) => PodcastEpisode.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<PodcastEpisode?> getPodcast(String id) async {
    try {
      final res = await _dio.get(Endpoints.mediaPodcast(id));
      final raw = res.data as Map<String, dynamic>;
      final data = raw['data'] as Map<String, dynamic>?;
      return data != null ? PodcastEpisode.fromJson(data) : null;
    } on DioException {
      return null;
    }
  }

  Future<void> updatePodcastProgress(String id, int seconds) async {
    try {
      await _dio.post(
        Endpoints.mediaPodcastProgress(id),
        data: {'progressSeconds': seconds},
      );
    } on DioException {
      // Non-critical
    }
  }

  // ── Albums ────────────────────────────────────────────────────────────────

  Future<List<PhotoAlbum>> getAlbums({int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.get(
        Endpoints.mediaAlbums,
        queryParameters: {'page': page, 'limit': limit},
      );
      final raw = res.data as Map<String, dynamic>;
      final list = (raw['data'] as List?) ?? [];
      return list
          .map((e) => PhotoAlbum.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<List<AlbumPhoto>> getAlbumPhotos(String albumId) async {
    try {
      final res = await _dio.get(Endpoints.mediaAlbumPhotos(albumId));
      final raw = res.data as Map<String, dynamic>;
      final list = (raw['data'] as List?) ?? [];
      return list
          .map((e) => AlbumPhoto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      return [];
    }
  }

  // ── Songs ─────────────────────────────────────────────────────────────────

  Future<List<Song>> getSongs({int page = 1, int limit = 50}) async {
    try {
      final res = await _dio.get(
        Endpoints.mediaSongs,
        queryParameters: {'page': page, 'limit': limit},
      );
      final raw = res.data as Map<String, dynamic>;
      final list = (raw['data'] as List?) ?? [];
      return list
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      return [];
    }
  }
}
