import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kids.dart';
import '../repositories/kids_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// KIDS CHECK-IN PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final kidsRepositoryProvider = Provider<KidsRepository>((_) => KidsRepository());

// ── State ──────────────────────────────────────────────────────────────────────

class KidsState {
  const KidsState({
    this.children = const [],
    this.rooms = const [],
    this.isLoading = false,
    this.error,
  });

  final List<KidsChild> children;
  final List<KidsRoom> rooms;
  final bool isLoading;
  final String? error;

  KidsState copyWith({
    List<KidsChild>? children,
    List<KidsRoom>? rooms,
    bool? isLoading,
    String? error,
  }) {
    return KidsState(
      children: children ?? this.children,
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class KidsNotifier extends Notifier<KidsState> {
  @override
  KidsState build() {
    Future.microtask(_load);
    return const KidsState(isLoading: true);
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(kidsRepositoryProvider);
      final results = await Future.wait([
        repo.fetchChildren(),
        repo.fetchRooms(),
      ]);
      state = KidsState(
        children: results[0] as List<KidsChild>,
        rooms: results[1] as List<KidsRoom>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _load();

  Future<void> addChild(
    String firstName,
    String lastName,
    String dateOfBirth, [
    String? allergies,
  ]) async {
    await ref.read(kidsRepositoryProvider).registerChild(
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: dateOfBirth,
          allergies: allergies,
        );
    await _load();
  }
}

// ── Provider ───────────────────────────────────────────────────────────────────

final kidsNotifierProvider =
    NotifierProvider<KidsNotifier, KidsState>(KidsNotifier.new);
