import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/community.dart';
import '../repositories/community_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// COMMUNITY PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final communityRepositoryProvider = Provider<CommunityRepository>((_) {
  return CommunityRepository();
});

// ── Groups ────────────────────────────────────────────────────────────────────

final groupsProvider = FutureProvider<List<ConnectGroup>>((ref) async {
  final res = await ref.watch(communityRepositoryProvider).getGroupsPaginated();
  if (!res.success) throw Exception(res.message);
  return res.data;
});

final groupDetailProvider =
    FutureProvider.family<GroupDetail?, String>((ref, id) async {
  final res = await ref.watch(communityRepositoryProvider).getGroup(id);
  if (!res.success) throw Exception(res.message);
  return res.data;
});

// ── Group membership notifier ─────────────────────────────────────────────────

class GroupMembershipNotifier extends StateNotifier<bool> {
  GroupMembershipNotifier(this._repo, this._groupId) : super(false);

  final CommunityRepository _repo;
  final String _groupId;

  Future<void> join() async {
    final res = await _repo.joinGroup(_groupId);
    if (res.success && mounted) state = true;
  }

  Future<void> leave() async {
    final res = await _repo.leaveGroup(_groupId);
    if (res.success && mounted) state = false;
  }
}

final groupMembershipProvider =
    StateNotifierProvider.family<GroupMembershipNotifier, bool, String>(
  (ref, groupId) => GroupMembershipNotifier(
    ref.read(communityRepositoryProvider),
    groupId,
  ),
);

// ── Announcements ─────────────────────────────────────────────────────────────

final announcementsFutureProvider =
    FutureProvider<List<Announcement>>((ref) async {
  final res = await ref.watch(communityRepositoryProvider).getAnnouncements();
  if (!res.success) throw Exception(res.message);
  return res.data;
});

class AnnouncementsNotifier extends Notifier<List<Announcement>> {
  @override
  List<Announcement> build() {
    Future.microtask(_load);
    return [];
  }

  Future<void> _load() async {
    final res = await ref.read(communityRepositoryProvider).getAnnouncements();
    if (res.success) state = res.data;
  }

  Future<void> refresh() => _load();

  Future<void> markRead(String id) async {
    await ref.read(communityRepositoryProvider).markAnnouncementRead(id);
    state = state.map((a) => a.id == id ? a.copyWith(isRead: true) : a).toList();
  }
}

final announcementsProvider =
    NotifierProvider<AnnouncementsNotifier, List<Announcement>>(
  AnnouncementsNotifier.new,
);

// ── Testimonies ───────────────────────────────────────────────────────────────

final testimoniesFutureProvider =
    FutureProvider<List<Testimony>>((ref) async {
  final res = await ref.watch(communityRepositoryProvider).getTestimonies();
  if (!res.success) throw Exception(res.message);
  return res.data;
});

class TestimoniesNotifier extends Notifier<List<Testimony>> {
  @override
  List<Testimony> build() {
    Future.microtask(_load);
    return [];
  }

  Future<void> _load() async {
    final res = await ref.read(communityRepositoryProvider).getTestimonies();
    if (res.success) state = res.data;
  }

  Future<void> refresh() => _load();

  Future<void> react(String id, String type) async {
    await ref.read(communityRepositoryProvider).reactTestimony(id, type);
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
    final res = await ref.read(communityRepositoryProvider).submitTestimony(
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

// ── Directory ─────────────────────────────────────────────────────────────────

final directoryProvider = FutureProvider<List<DirectoryMember>>((ref) async {
  final res = await ref.watch(communityRepositoryProvider).getDirectory();
  if (!res.success) throw Exception(res.message);
  return res.data;
});

// ── Invite ────────────────────────────────────────────────────────────────────

class InviteNotifier extends Notifier<InviteInfo?> {
  @override
  InviteInfo? build() => null;

  Future<bool> generate() async {
    final res = await ref.read(communityRepositoryProvider).generateInvite();
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
  final res = await ref.watch(communityRepositoryProvider).getInviteStats();
  return res.success ? res.data : null;
});

// ── Connect Groups filter state ───────────────────────────────────────────────

class ConnectGroupsState {
  const ConnectGroupsState({
    this.selectedCategory = 0,
    this.searchQuery = '',
  });

  final int selectedCategory;
  final String searchQuery;

  ConnectGroupsState copyWith({int? selectedCategory, String? searchQuery}) {
    return ConnectGroupsState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ConnectGroupsNotifier extends StateNotifier<ConnectGroupsState> {
  ConnectGroupsNotifier() : super(const ConnectGroupsState());

  void selectCategory(int index) =>
      state = state.copyWith(selectedCategory: index);

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);
}

final connectGroupsNotifierProvider =
    StateNotifierProvider<ConnectGroupsNotifier, ConnectGroupsState>(
        (_) => ConnectGroupsNotifier());
