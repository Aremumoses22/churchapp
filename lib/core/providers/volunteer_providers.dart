import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/volunteer.dart';
import '../repositories/volunteer_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// VOLUNTEER PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final volunteerRepositoryProvider =
    Provider<VolunteerRepository>((_) => VolunteerRepository());

// ── Opportunities notifier (supports sign-up mutation) ────────────────────────

class VolunteerOpportunitiesNotifier
    extends Notifier<List<VolunteerOpportunity>> {
  String? _ministryFilter;

  @override
  List<VolunteerOpportunity> build() {
    Future.microtask(() => _load());
    return [];
  }

  Future<void> _load() async {
    final items = await ref
        .read(volunteerRepositoryProvider)
        .getOpportunities(ministry: _ministryFilter);
    state = items;
  }

  Future<void> filterByMinistry(String? ministry) async {
    _ministryFilter = ministry;
    await _load();
  }

  Future<bool> signUp(String opportunityId) async {
    final res =
        await ref.read(volunteerRepositoryProvider).signUp(opportunityId);
    if (res.success) {
      state = state.map((o) {
        if (o.id != opportunityId) return o;
        return o.copyWith(isSignedUp: true);
      }).toList();
      return true;
    }
    return false;
  }
}

final volunteerOpportunitiesProvider =
    NotifierProvider<VolunteerOpportunitiesNotifier, List<VolunteerOpportunity>>(
  VolunteerOpportunitiesNotifier.new,
);

// ── Roster notifier ───────────────────────────────────────────────────────────

class RosterNotifier extends Notifier<List<RosterShift>> {
  @override
  List<RosterShift> build() {
    Future.microtask(_load);
    return [];
  }

  Future<void> _load() async {
    final items =
        await ref.read(volunteerRepositoryProvider).getRoster();
    state = items;
  }

  Future<void> refresh() => _load();

  Future<bool> checkIn(String shiftId) async {
    final res =
        await ref.read(volunteerRepositoryProvider).checkIn(shiftId);
    if (res.success) {
      state = state.map((s) {
        if (s.id != shiftId) return s;
        return s.copyWith(checkedIn: true);
      }).toList();
      return true;
    }
    return false;
  }
}

final rosterProvider =
    NotifierProvider<RosterNotifier, List<RosterShift>>(RosterNotifier.new);
