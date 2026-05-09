import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';
import '../repositories/event_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// EVENT PROVIDERS — §6 Events Endpoints
// ──────────────────────────────────────────────────────────────────────────────

final eventRepositoryProvider =
    Provider<EventRepository>((_) => EventRepository());

// ── State ────────────────────────────────────────────────────────────────────

class EventState {
  const EventState({
    this.events = const [],
    this.featuredEvents = const [],
    this.myEvents = const [],
    this.viewMode = 0,
    this.focusMonth,
    this.selectedDay,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.selectedCategory,
    this.timeUntilNext = Duration.zero,
  });

  final List<Event> events;
  final List<Event> featuredEvents;
  final List<Event> myEvents;
  final int viewMode; // 0=List, 1=Calendar, 2=Map
  final DateTime? focusMonth;
  final int? selectedDay;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? selectedCategory;
  final Duration timeUntilNext;

  /// Group events by day-of-month for the calendar view.
  Map<int, List<Event>> get eventsByDay {
    final map = <int, List<Event>>{};
    for (final e in events) {
      final day = e.startDate.day;
      map.putIfAbsent(day, () => []).add(e);
    }
    return map;
  }

  /// Next upcoming event (soonest startDate in the future).
  Event? get nextEvent {
    final now = DateTime.now();
    final upcoming = events.where((e) => e.startDate.isAfter(now)).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  String get nextEventTitle => nextEvent?.title ?? '';
  DateTime? get nextEventTime => nextEvent?.startDate;

  EventState copyWith({
    List<Event>? events,
    List<Event>? featuredEvents,
    List<Event>? myEvents,
    int? viewMode,
    DateTime? focusMonth,
    int? selectedDay,
    bool clearSelectedDay = false,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    int? currentPage,
    bool? hasMore,
    String? selectedCategory,
    bool clearCategory = false,
    Duration? timeUntilNext,
  }) {
    return EventState(
      events: events ?? this.events,
      featuredEvents: featuredEvents ?? this.featuredEvents,
      myEvents: myEvents ?? this.myEvents,
      viewMode: viewMode ?? this.viewMode,
      focusMonth: focusMonth ?? this.focusMonth,
      selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      timeUntilNext: timeUntilNext ?? this.timeUntilNext,
    );
  }

  List<Event> get allEvents => events;
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class EventNotifier extends Notifier<EventState> {
  late final EventRepository _repo;
  Timer? _timer;

  @override
  EventState build() {
    _repo = ref.watch(eventRepositoryProvider);
    ref.onDispose(() => _timer?.cancel());
    Future.microtask(() => loadInitial());
    return const EventState(isLoading: true);
  }

  // ── Initial load ──────────────────────────────────────────────────────────
  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repo.getEvents(page: 1, filter: 'upcoming'),
        _repo.getFeatured(),
      ]);

      final eventsRes = results[0] as dynamic;
      final featuredRes = results[1] as dynamic;

      state = state.copyWith(
        events: eventsRes.data ?? <Event>[],
        featuredEvents: featuredRes.data ?? <Event>[],
        focusMonth: DateTime(DateTime.now().year, DateTime.now().month),
        currentPage: 1,
        hasMore: eventsRes.meta?.hasNextPage ?? false,
        isLoading: false,
      );
      _startCountdown();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ── Load more (pagination) ────────────────────────────────────────────────
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final res = await _repo.getEvents(
        page: nextPage,
        filter: 'upcoming',
        category: state.selectedCategory,
      );
      state = state.copyWith(
        events: [...state.events, ...res.data],
        currentPage: nextPage,
        hasMore: res.meta?.hasNextPage ?? false,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  // ── Filter by category ────────────────────────────────────────────────────
  Future<void> filterByCategory(String? category) async {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
      isLoading: true,
    );
    try {
      final res = await _repo.getEvents(
        page: 1,
        filter: 'upcoming',
        category: category,
      );
      state = state.copyWith(
        events: res.data,
        currentPage: 1,
        hasMore: res.meta?.hasNextPage ?? false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ── Load my events ────────────────────────────────────────────────────────
  Future<void> loadMyEvents() async {
    try {
      final res = await _repo.getMyEvents();
      if (res.success && res.data != null) {
        state = state.copyWith(myEvents: res.data);
      }
    } catch (_) {}
  }

  // ── Register / Unregister ─────────────────────────────────────────────────
  Future<bool> registerForEvent(String eventId) async {
    try {
      final res = await _repo.registerForEvent(eventId);
      if (res.success) {
        // Update local state
        final updated = state.events.map((e) {
          if (e.id == eventId) {
            return e.copyWith(
              isRegistered: true,
              registeredCount: e.registeredCount + 1,
            );
          }
          return e;
        }).toList();
        state = state.copyWith(events: updated);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unregisterFromEvent(String eventId) async {
    try {
      final res = await _repo.unregisterFromEvent(eventId);
      if (res.success) {
        final updated = state.events.map((e) {
          if (e.id == eventId) {
            return e.copyWith(
              isRegistered: false,
              registeredCount: (e.registeredCount - 1).clamp(0, 999999),
            );
          }
          return e;
        }).toList();
        state = state.copyWith(events: updated);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── View helpers ──────────────────────────────────────────────────────────
  void setViewMode(int mode) => state = state.copyWith(viewMode: mode);

  void setFocusMonth(DateTime month) =>
      state = state.copyWith(focusMonth: month);

  void selectDay(int? day) {
    if (day == null) {
      state = state.copyWith(clearSelectedDay: true);
    } else {
      state = state.copyWith(selectedDay: day);
    }
  }

  // ── Countdown timer ───────────────────────────────────────────────────────
  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.nextEventTime;
      if (next == null) return;
      final diff = next.difference(DateTime.now());
      if (diff.isNegative) {
        _timer?.cancel();
        return;
      }
      state = state.copyWith(timeUntilNext: diff);
    });
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final eventNotifierProvider =
    NotifierProvider<EventNotifier, EventState>(EventNotifier.new);

// ── Detail Provider (FutureProvider.family) ──────────────────────────────────

final eventDetailProvider =
    FutureProvider.family<Event, String>((ref, eventId) async {
  final repo = ref.watch(eventRepositoryProvider);
  final res = await repo.getEvent(eventId);
  if (!res.success || res.data == null) {
    throw Exception(res.message ?? 'Failed to load event');
  }
  return res.data!;
});

