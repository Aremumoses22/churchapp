import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/sermon.dart';
import '../repositories/sermon_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SERMON PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final sermonRepositoryProvider = Provider<SermonRepository>((_) {
  return MockSermonRepository();
});

// ── State ────────────────────────────────────────────────────────────────────

class SermonState {
  const SermonState({
    this.sermons = const [],
    this.series = const [],
    this.selectedFilter = 0,
    this.searchQuery = '',
    this.isPlaying = true,
    this.nowPlayingTitle = 'The Power of Faith',
    this.nowPlayingSpeaker = 'Pastor James',
    this.nowPlayingProgress = 0.35,
  });

  final List<Sermon> sermons;
  final List<SermonSeries> series;
  final int selectedFilter;
  final String searchQuery;
  final bool isPlaying;
  final String nowPlayingTitle;
  final String nowPlayingSpeaker;
  final double nowPlayingProgress;

  SermonState copyWith({
    List<Sermon>? sermons,
    List<SermonSeries>? series,
    int? selectedFilter,
    String? searchQuery,
    bool? isPlaying,
    String? nowPlayingTitle,
    String? nowPlayingSpeaker,
    double? nowPlayingProgress,
  }) {
    return SermonState(
      sermons: sermons ?? this.sermons,
      series: series ?? this.series,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isPlaying: isPlaying ?? this.isPlaying,
      nowPlayingTitle: nowPlayingTitle ?? this.nowPlayingTitle,
      nowPlayingSpeaker: nowPlayingSpeaker ?? this.nowPlayingSpeaker,
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
        list = list.where((s) => s.series != null).toList();
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

class SermonNotifier extends StateNotifier<SermonState> {
  SermonNotifier(this._repo) : super(const SermonState()) {
    _init();
  }
  final SermonRepository _repo;

  void _init() {
    state = state.copyWith(
      sermons: _repo.getSermons(),
      series: _repo.getSeries(),
      nowPlayingTitle: _repo.nowPlayingTitle,
      nowPlayingSpeaker: _repo.nowPlayingSpeaker,
      nowPlayingProgress: _repo.nowPlayingProgress,
    );
  }

  void setFilter(int index) => state = state.copyWith(selectedFilter: index);

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);

  void togglePlaying() => state = state.copyWith(isPlaying: !state.isPlaying);

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

final sermonNotifierProvider =
    StateNotifierProvider<SermonNotifier, SermonState>((ref) {
  return SermonNotifier(ref.watch(sermonRepositoryProvider));
});
