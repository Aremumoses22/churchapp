import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/search.dart';
import '../repositories/search_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SEARCH PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final searchRepositoryProvider = Provider<SearchRepository>((_) {
  return MockSearchRepository();
});

// ── State ────────────────────────────────────────────────────────────────────

class SearchState {
  const SearchState({
    this.allItems = const [],
    this.recentSearches = const [],
    this.trending = const [],
    this.query = '',
  });

  final List<SearchItem> allItems;
  final List<String> recentSearches;
  final List<String> trending;
  final String query;

  SearchState copyWith({
    List<SearchItem>? allItems,
    List<String>? recentSearches,
    List<String>? trending,
    String? query,
  }) {
    return SearchState(
      allItems: allItems ?? this.allItems,
      recentSearches: recentSearches ?? this.recentSearches,
      trending: trending ?? this.trending,
      query: query ?? this.query,
    );
  }

  bool get hasQuery => query.trim().isNotEmpty;

  List<SearchItem> get results {
    if (!hasQuery) return [];
    final q = query.toLowerCase();
    return allItems
        .where((item) =>
            item.title.toLowerCase().contains(q) ||
            item.subtitle.toLowerCase().contains(q) ||
            item.category.toLowerCase().contains(q))
        .toList();
  }

  /// Results grouped by category.
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
    _init();
  }
  final SearchRepository _repo;

  void _init() {
    state = state.copyWith(
      allItems: _repo.getAllItems(),
      recentSearches: _repo.getDefaultRecentSearches(),
      trending: _repo.getTrending(),
    );
  }

  void setQuery(String q) => state = state.copyWith(query: q);

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

  void clearRecentSearches() =>
      state = state.copyWith(recentSearches: []);
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(searchRepositoryProvider));
});
