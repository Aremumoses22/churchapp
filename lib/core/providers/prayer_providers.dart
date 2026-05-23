import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/prayer.dart';
import '../repositories/prayer_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PRAYER PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final prayerRepositoryProvider =
    Provider<PrayerRepository>((_) => PrayerRepository());

// ── My prayer requests (notifier so we can mutate after submit/pray) ──────────

class PrayerRequestsNotifier extends Notifier<List<PrayerRequest>> {
  @override
  List<PrayerRequest> build() {
    Future.microtask(_load);
    return [];
  }

  Future<void> _load() async {
    final res = await ref.read(prayerRepositoryProvider).getMyRequests();
    if (res.success && res.data != null) state = res.data!;
  }

  Future<void> refresh() => _load();

  Future<bool> submit({
    required String title,
    String? content,
    bool isAnonymous = false,
    bool isUrgent = false,
  }) async {
    final res = await ref.read(prayerRepositoryProvider).submitRequest(
          title: title,
          content: content,
          isAnonymous: isAnonymous,
          isUrgent: isUrgent,
        );
    if (res.success && res.data != null) {
      state = [res.data!, ...state];
      return true;
    }
    return false;
  }

  Future<void> prayFor(String id) async {
    await ref.read(prayerRepositoryProvider).prayForRequest(id);
    state = state.map((r) {
      if (r.id != id) return r;
      return r.copyWith(
        hasPrayed: true,
        prayerCount: r.prayerCount + 1,
      );
    }).toList();
  }
}

final prayerRequestsProvider =
    NotifierProvider<PrayerRequestsNotifier, List<PrayerRequest>>(
  PrayerRequestsNotifier.new,
);
