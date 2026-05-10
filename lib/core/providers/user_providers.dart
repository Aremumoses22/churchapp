import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../repositories/user_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// USER PROVIDERS — §4 User Endpoints
// ──────────────────────────────────────────────────────────────────────────────

final userRepositoryProvider =
    Provider<UserRepository>((_) => UserRepository());

// ── State ────────────────────────────────────────────────────────────────────

class UserState {
  const UserState({
    this.profile,
    this.attendance,
    this.milestones = const [],
    this.savedItems = const [],
    this.isLoading = false,
    this.error,
  });

  final UserProfile? profile;
  final AttendanceData? attendance;
  final List<Milestone> milestones;
  final List<SavedItem> savedItems;
  final bool isLoading;
  final String? error;

  UserState copyWith({
    UserProfile? profile,
    AttendanceData? attendance,
    List<Milestone>? milestones,
    List<SavedItem>? savedItems,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return UserState(
      profile: profile ?? this.profile,
      attendance: attendance ?? this.attendance,
      milestones: milestones ?? this.milestones,
      savedItems: savedItems ?? this.savedItems,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class UserNotifier extends Notifier<UserState> {
  late final UserRepository _repo;

  @override
  UserState build() {
    _repo = ref.watch(userRepositoryProvider);
    return const UserState();
  }

  // ── Fetch profile ─────────────────────────────────────────────────────────
  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _repo.getProfile();
      if (res.success && res.data != null) {
        state = state.copyWith(profile: res.data, isLoading: false);
      } else {
        state = state.copyWith(
            error: res.message ?? 'Failed to load profile', isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ── Update profile ────────────────────────────────────────────────────────
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? department,
    bool? isDirectoryVisible,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _repo.updateProfile(
        name: name,
        phone: phone,
        bio: bio,
        department: department,
        isDirectoryVisible: isDirectoryVisible,
      );
      if (res.success && res.data != null) {
        state = state.copyWith(profile: res.data, isLoading: false);
        return true;
      }
      state = state.copyWith(
          error: res.message ?? 'Update failed', isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  // ── Upload avatar ─────────────────────────────────────────────────────────
  Future<bool> uploadAvatar(String filePath) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _repo.uploadAvatar(filePath);
      if (res.success && res.data != null) {
        state = state.copyWith(profile: res.data, isLoading: false);
        return true;
      }
      state = state.copyWith(
          error: res.message ?? 'Upload failed', isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  // ── Update notification prefs ─────────────────────────────────────────────
  Future<bool> updateNotificationPrefs(Map<String, bool> prefs) async {
    try {
      final res = await _repo.updateNotificationPrefs(prefs);
      return res.success;
    } catch (_) {
      return false;
    }
  }

  // ── Register FCM token ────────────────────────────────────────────────────
  Future<void> registerFcmToken(String token) async {
    try {
      await _repo.registerFcmToken(token);
    } catch (_) {
      // Silently fail — non-critical
    }
  }

  // ── Fetch attendance ──────────────────────────────────────────────────────
  Future<void> fetchAttendance() async {
    try {
      final res = await _repo.getAttendance();
      if (res.success && res.data != null) {
        state = state.copyWith(attendance: res.data);
      }
    } catch (_) {}
  }

  // ── Fetch milestones ──────────────────────────────────────────────────────
  Future<void> fetchMilestones() async {
    try {
      final res = await _repo.getMilestones();
      if (res.success && res.data != null) {
        state = state.copyWith(milestones: res.data);
      }
    } catch (_) {}
  }

  // ── Fetch saved items ─────────────────────────────────────────────────────
  Future<void> fetchSavedItems() async {
    try {
      final res = await _repo.getSavedItems();
      if (res.success && res.data != null) {
        state = state.copyWith(savedItems: res.data);
      }
    } catch (_) {}
  }

  // ── Save item ─────────────────────────────────────────────────────────────
  Future<bool> saveItem({
    required String entityType,
    required String entityId,
  }) async {
    try {
      final res =
          await _repo.saveItem(entityType: entityType, entityId: entityId);
      if (res.success) {
        await fetchSavedItems();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── Remove saved item ─────────────────────────────────────────────────────
  Future<bool> removeSavedItem(String id) async {
    try {
      final res = await _repo.removeSavedItem(id);
      if (res.success) {
        state = state.copyWith(
          savedItems: state.savedItems.where((s) => s.id != id).toList(),
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final userNotifierProvider =
    NotifierProvider<UserNotifier, UserState>(UserNotifier.new);
