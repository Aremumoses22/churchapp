import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/search.dart';
import '../repositories/search_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SEARCH PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final searchRepositoryProvider = Provider<SearchRepository>((_) {
  return SearchRepository();
});

// ── State ────────────────────────────────────────────────────────────────────

class SearchState {
  const SearchState({
    this.results = const [],
    this.recentSearches = const [],
    this.trending = const [],
    this.query = '',
    this.isLoading = false,
    this.error,
  });

  final List<SearchItem> results;
  final List<String> recentSearches;
  final List<String> trending;
  final String query;
  final bool isLoading;
  final String? error;

  SearchState copyWith({
    List<SearchItem>? results,
    List<String>? recentSearches,
    List<String>? trending,
    String? query,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      trending: trending ?? this.trending,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasQuery => query.trim().isNotEmpty;

  Map<String, List<SearchItem>> get groupedResults {
    final map = <String, List<SearchItem>>{};
    for (final item in results) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._repo) : super(const SearchState()) {
    _loadTrending();
  }
  final SearchRepository _repo;

  Future<void> _loadTrending() async {
    final trending = await _repo.getTrending();
    if (!mounted) return;
    state = state.copyWith(trending: trending);
  }

  Future<void> setQuery(String q) async {
    state = state.copyWith(query: q, error: null);
    if (q.trim().isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }
    state = state.copyWith(isLoading: true);
    final items = await _repo.search(q.trim());
    if (!mounted) return;
    state = state.copyWith(results: items, isLoading: false);
  }

  void addRecentSearch(String term) {
    if (term.trim().isEmpty) return;
    final list = List<String>.from(state.recentSearches);
    list.remove(term);
    list.insert(0, term);
    if (list.length > 10) list.removeLast();
    state = state.copyWith(recentSearches: list);
  }

  void removeRecentSearch(String term) {
    state = state.copyWith(
      recentSearches: state.recentSearches.where((s) => s != term).toList(),
    );
  }

  void clearRecentSearches() => state = state.copyWith(recentSearches: []);
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(searchRepositoryProvider));
});
