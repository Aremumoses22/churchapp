import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sermon.dart';
import '../repositories/sermon_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SERMON PROVIDERS — §5 Sermons Endpoints
// ──────────────────────────────────────────────────────────────────────────────

final sermonRepositoryProvider =
    Provider<SermonRepository>((_) => SermonRepository());

// ── State ────────────────────────────────────────────────────────────────────

class SermonState {
  const SermonState({
    this.sermons = const [],
    this.series = const [],
    this.featuredSermons = const [],
    this.savedSermons = const [],
    this.selectedFilter = 0,
    this.searchQuery = '',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    // Now Playing
    this.isPlaying = false,
    this.nowPlayingSermon,
    this.nowPlayingProgress = 0.0,
  });

  final List<Sermon> sermons;
  final List<SermonSeries> series;
  final List<Sermon> featuredSermons;
  final List<Sermon> savedSermons;
  final int selectedFilter;
  final String searchQuery;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  // Now Playing
  final bool isPlaying;
  final Sermon? nowPlayingSermon;
  final double nowPlayingProgress;

  String get nowPlayingTitle => nowPlayingSermon?.title ?? '';
  String get nowPlayingSpeaker => nowPlayingSermon?.speaker ?? '';

  SermonState copyWith({
    List<Sermon>? sermons,
    List<SermonSeries>? series,
    List<Sermon>? featuredSermons,
    List<Sermon>? savedSermons,
    int? selectedFilter,
    String? searchQuery,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    int? currentPage,
    bool? hasMore,
    bool? isPlaying,
    Sermon? nowPlayingSermon,
    bool clearNowPlaying = false,
    double? nowPlayingProgress,
  }) {
    return SermonState(
      sermons: sermons ?? this.sermons,
      series: series ?? this.series,
      featuredSermons: featuredSermons ?? this.featuredSermons,
      savedSermons: savedSermons ?? this.savedSermons,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isPlaying: isPlaying ?? this.isPlaying,
      nowPlayingSermon:
          clearNowPlaying ? null : (nowPlayingSermon ?? this.nowPlayingSermon),
      nowPlayingProgress: nowPlayingProgress ?? this.nowPlayingProgress,
    );
  }

  /// Sermons filtered by current search query and selected chip.
  List<Sermon> get filteredSermons {
    var list = sermons;
    // Search
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where((s) =>
              s.title.toLowerCase().contains(q) ||
              s.speaker.toLowerCase().contains(q))
          .toList();
    }
    // Filter chips: 0=All, 1=Latest, 2=Popular, 3=Series, 4=Downloaded
    switch (selectedFilter) {
      case 3:
        list = list.where((s) => s.seriesId != null).toList();
      case 4:
        list = list
            .where((s) => s.downloadState == DownloadState.downloaded)
            .toList();
      default:
        break;
    }
    return list;
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class SermonNotifier extends Notifier<SermonState> {
  late final SermonRepository _repo;

  @override
  SermonState build() {
    _repo = ref.watch(sermonRepositoryProvider);
    // Auto-fetch sermons on creation
    Future.microtask(() => loadInitial());
    return const SermonState(isLoading: true);
  }

  // ── Initial load ──────────────────────────────────────────────────────────
  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repo.getSermons(page: 1),
        _repo.getAllSeries(),
        _repo.getFeatured(),
      ]);

      final sermonsRes = results[0] as dynamic;
      final seriesRes = results[1] as dynamic;
      final featuredRes = results[2] as dynamic;

      state = state.copyWith(
        sermons: sermonsRes.data ?? <Sermon>[],
        series: seriesRes.data ?? <SermonSeries>[],
        featuredSermons: featuredRes.data ?? <Sermon>[],
        currentPage: 1,
        hasMore: sermonsRes.meta?.hasNextPage ?? false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ── Load more (pagination) ────────────────────────────────────────────────
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final res = await _repo.getSermons(
        page: nextPage,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
      state = state.copyWith(
        sermons: [...state.sermons, ...res.data],
        currentPage: nextPage,
        hasMore: res.meta?.hasNextPage ?? false,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────
  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    if (query.isEmpty) {
      await loadInitial();
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final res = await _repo.getSermons(page: 1, search: query);
      state = state.copyWith(
        sermons: res.data,
        currentPage: 1,
        hasMore: res.meta?.hasNextPage ?? false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ── Filter ────────────────────────────────────────────────────────────────
  void setFilter(int index) => state = state.copyWith(selectedFilter: index);

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);

  // ── Saved sermons ─────────────────────────────────────────────────────────
  Future<void> loadSaved() async {
    try {
      final res = await _repo.getSaved();
      if (res.success && res.data != null) {
        state = state.copyWith(savedSermons: res.data);
      }
    } catch (_) {}
  }

  // ── Toggle save ───────────────────────────────────────────────────────────
  Future<void> toggleSave(String sermonId) async {
    try {
      await _repo.toggleSave(sermonId);
      // Update local state
      final updated = state.sermons.map((s) {
        if (s.id == sermonId) return s.copyWith(isSaved: !s.isSaved);
        return s;
      }).toList();
      state = state.copyWith(sermons: updated);
      await loadSaved();
    } catch (_) {}
  }

  // ── Save progress ─────────────────────────────────────────────────────────
  Future<void> saveProgress(String sermonId, int position,
      {bool completed = false}) async {
    try {
      await _repo.saveProgress(
        sermonId: sermonId,
        position: position,
        completed: completed,
      );
    } catch (_) {}
  }

  // ── Now Playing ───────────────────────────────────────────────────────────
  void setNowPlaying(Sermon sermon) {
    state = state.copyWith(
      nowPlayingSermon: sermon,
      isPlaying: true,
      nowPlayingProgress: 0.0,
    );
  }

  void togglePlaying() => state = state.copyWith(isPlaying: !state.isPlaying);

  void updateProgress(double progress) =>
      state = state.copyWith(nowPlayingProgress: progress);

  void clearNowPlaying() => state = state.copyWith(
        clearNowPlaying: true,
        isPlaying: false,
        nowPlayingProgress: 0.0,
      );

  // ── Download (local-only state) ───────────────────────────────────────────
  void updateDownloadState(String sermonId, DownloadState ds,
      [double progress = 0.0]) {
    final updated = state.sermons.map((s) {
      if (s.id == sermonId) {
        return s.copyWith(downloadState: ds, downloadProgress: progress);
      }
      return s;
    }).toList();
    state = state.copyWith(sermons: updated);
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final sermonNotifierProvider =
    NotifierProvider<SermonNotifier, SermonState>(SermonNotifier.new);

// ── Detail Providers (FutureProvider.family) ─────────────────────────────────

final sermonDetailProvider =
    FutureProvider.family<Sermon, String>((ref, sermonId) async {
  final repo = ref.watch(sermonRepositoryProvider);
  final res = await repo.getSermon(sermonId);
  if (!res.success || res.data == null) {
    throw Exception(res.message ?? 'Failed to load sermon');
  }
  return res.data!;
});

final seriesDetailProvider =
    FutureProvider.family<SermonSeries, String>((ref, seriesId) async {
  final repo = ref.watch(sermonRepositoryProvider);
  final res = await repo.getSeries(seriesId);
  if (!res.success || res.data == null) {
    throw Exception(res.message ?? 'Failed to load series');
  }
  return res.data!;
});

final sermonStreamProvider =
    FutureProvider.family<SermonStreamInfo, String>((ref, sermonId) async {
  final repo = ref.watch(sermonRepositoryProvider);
  final res = await repo.getStreamUrl(sermonId);
  if (!res.success || res.data == null) {
    throw Exception(res.message ?? 'Failed to get stream URL');
  }
  return res.data!;
});

final sermonNotesProvider =
    FutureProvider.family<SermonNote?, String>((ref, sermonId) async {
  final repo = ref.watch(sermonRepositoryProvider);
  final res = await repo.getNotes(sermonId);
  return res.data;
});

