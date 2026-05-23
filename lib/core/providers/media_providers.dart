import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media.dart';
import '../repositories/media_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// MEDIA PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final mediaRepositoryProvider =
    Provider<MediaRepository>((_) => MediaRepository());

// ── Podcasts ──────────────────────────────────────────────────────────────────

final podcastsProvider = FutureProvider<List<PodcastEpisode>>((ref) async {
  return ref.watch(mediaRepositoryProvider).getPodcasts();
});

// ── Albums ────────────────────────────────────────────────────────────────────

final albumsProvider = FutureProvider<List<PhotoAlbum>>((ref) async {
  return ref.watch(mediaRepositoryProvider).getAlbums();
});

final albumPhotosProvider =
    FutureProvider.family<List<AlbumPhoto>, String>((ref, albumId) async {
  return ref.watch(mediaRepositoryProvider).getAlbumPhotos(albumId);
});

// ── Songs ─────────────────────────────────────────────────────────────────────

final songsProvider = FutureProvider<List<Song>>((ref) async {
  return ref.watch(mediaRepositoryProvider).getSongs();
});
