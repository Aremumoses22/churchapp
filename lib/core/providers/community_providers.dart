import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/community.dart';
import '../repositories/community_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// COMMUNITY PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final communityRepositoryProvider = Provider<CommunityRepository>((_) {
  return MockCommunityRepository();
});

// ── State ────────────────────────────────────────────────────────────────────

class CommunityState {
  const CommunityState({
    this.groups = const [],
    this.categories = const [],
    this.selectedCategory = 0,
  });

  final List<ConnectGroup> groups;
  final List<String> categories;
  final int selectedCategory;

  CommunityState copyWith({
    List<ConnectGroup>? groups,
    List<String>? categories,
    int? selectedCategory,
  }) {
    return CommunityState(
      groups: groups ?? this.groups,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  List<ConnectGroup> get filteredGroups {
    if (selectedCategory == 0) return groups;
    final cat = categories[selectedCategory];
    return groups.where((g) => g.category == cat).toList();
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class CommunityNotifier extends StateNotifier<CommunityState> {
  CommunityNotifier(this._repo) : super(const CommunityState()) {
    _init();
  }
  final CommunityRepository _repo;

  void _init() {
    state = state.copyWith(
      groups: _repo.getGroups(),
      categories: _repo.getCategories(),
    );
  }

  void selectCategory(int index) =>
      state = state.copyWith(selectedCategory: index);
}

final communityNotifierProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier(ref.watch(communityRepositoryProvider));
});
