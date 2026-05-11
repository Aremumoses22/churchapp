import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/community.dart';
import '../repositories/community_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// COMMUNITY PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final communityRepositoryProvider = Provider<MockCommunityRepository>((_) {
  return MockCommunityRepository();
});

final apiCommunityRepositoryProvider = Provider<ApiCommunityRepository>((_) {
  return ApiCommunityRepository();
});

// ── Groups API providers ──────────────────────────────────────────────────────

final groupsProvider = FutureProvider<List<ConnectGroup>>((ref) async {
  final res = await ref
      .watch(apiCommunityRepositoryProvider)
      .getGroupsPaginated();
  return res.data;
});

final groupDetailProvider =
    FutureProvider.family<GroupDetail?, String>((ref, id) async {
  final res =
      await ref.watch(apiCommunityRepositoryProvider).getGroup(id);
  return res.success ? res.data : null;
});

// ── Group membership notifier ─────────────────────────────────────────────────

class GroupMembershipNotifier extends StateNotifier<bool> {
  GroupMembershipNotifier(this._repo, this._groupId) : super(false);

  final ApiCommunityRepository _repo;
  final String _groupId;

  Future<void> join() async {
    final res = await _repo.joinGroup(_groupId);
    if (res.success) state = true;
  }

  Future<void> leave() async {
    final res = await _repo.leaveGroup(_groupId);
    if (res.success) state = false;
  }
}

final groupMembershipProvider =
    StateNotifierProvider.family<GroupMembershipNotifier, bool, String>(
  (ref, groupId) => GroupMembershipNotifier(
    ref.read(apiCommunityRepositoryProvider),
    groupId,
  ),
);

// ── Announcements ─────────────────────────────────────────────────────────────

class AnnouncementsNotifier extends Notifier<List<Announcement>> {
  @override
  List<Announcement> build() => [];

  Future<void> load() async {
    final res = await ref
        .read(apiCommunityRepositoryProvider)
        .getAnnouncements();
    state = res.data;
  }

  Future<void> markRead(String id) async {
    await ref.read(apiCommunityRepositoryProvider).markAnnouncementRead(id);
    state = state
        .map((a) => a.id == id ? a.copyWith(isRead: true) : a)
        .toList();
  }
}

final announcementsProvider =
    NotifierProvider<AnnouncementsNotifier, List<Announcement>>(
  AnnouncementsNotifier.new,
);

final announcementsFutureProvider =
    FutureProvider<List<Announcement>>((ref) async {
  final res = await ref
      .watch(apiCommunityRepositoryProvider)
      .getAnnouncements();
  return res.data;
});

// ── Testimonies ───────────────────────────────────────────────────────────────

class TestimoniesNotifier extends Notifier<List<Testimony>> {
  @override
  List<Testimony> build() => [];

  Future<void> load() async {
    final res = await ref
        .read(apiCommunityRepositoryProvider)
        .getTestimonies();
    state = res.data;
  }

  Future<void> react(String id, String type) async {
    await ref.read(apiCommunityRepositoryProvider).reactTestimony(id, type);
    state = state.map((t) {
      if (t.id != id) return t;
      if (type == 'LIKE') {
        return t.copyWith(
          hasLiked: !t.hasLiked,
          likeCount: t.hasLiked ? t.likeCount - 1 : t.likeCount + 1,
        );
      } else {
        return t.copyWith(
          hasPrayed: !t.hasPrayed,
          prayCount: t.hasPrayed ? t.prayCount - 1 : t.prayCount + 1,
        );
      }
    }).toList();
  }

  Future<bool> submit({
    required String title,
    required String content,
    bool isAnonymous = false,
  }) async {
    final res = await ref.read(apiCommunityRepositoryProvider).submitTestimony(
          title: title,
          content: content,
          isAnonymous: isAnonymous,
        );
    return res.success;
  }
}

final testimoniesProvider =
    NotifierProvider<TestimoniesNotifier, List<Testimony>>(
  TestimoniesNotifier.new,
);

final testimoniesFutureProvider =
    FutureProvider<List<Testimony>>((ref) async {
  final res = await ref
      .watch(apiCommunityRepositoryProvider)
      .getTestimonies();
  return res.data;
});

// ── Directory ─────────────────────────────────────────────────────────────────

final directoryProvider = FutureProvider<List<DirectoryMember>>((ref) async {
  final res =
      await ref.watch(apiCommunityRepositoryProvider).getDirectory();
  return res.data;
});

// ── Invite ────────────────────────────────────────────────────────────────────

class InviteNotifier extends Notifier<InviteInfo?> {
  @override
  InviteInfo? build() => null;

  Future<bool> generate() async {
    final res =
        await ref.read(apiCommunityRepositoryProvider).generateInvite();
    if (res.success && res.data != null) {
      state = res.data;
      return true;
    }
    return false;
  }
}

final inviteProvider = NotifierProvider<InviteNotifier, InviteInfo?>(
  InviteNotifier.new,
);

final inviteStatsProvider = FutureProvider<InviteStats?>((ref) async {
  final res =
      await ref.watch(apiCommunityRepositoryProvider).getInviteStats();
  return res.success ? res.data : null;
});

// ── Legacy local state (Connect Groups screen fallback) ───────────────────────

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
    return groups
        .where((g) =>
            g.category.toLowerCase() == cat.toLowerCase() ||
            g.category.toUpperCase() ==
                cat.toUpperCase().replaceAll(' ', '_'))
        .toList();
  }
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  CommunityNotifier(this._repo) : super(const CommunityState()) {
    _init();
  }
  final MockCommunityRepository _repo;

  void _init() {
    state = state.copyWith(
      groups: _repo.getGroups(),
      categories: _repo.getCategories(),
    );
  }

  void selectCategory(int index) =>
      state = state.copyWith(selectedCategory: index);

  void updateGroupsFromApi(List<ConnectGroup> apiGroups) {
    state = state.copyWith(groups: apiGroups);
  }
}

final communityNotifierProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier(ref.watch(communityRepositoryProvider));
});
