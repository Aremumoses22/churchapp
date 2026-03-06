import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/event.dart';
import '../repositories/event_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// EVENT PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final eventRepositoryProvider = Provider<EventRepository>((_) {
  return MockEventRepository();
});

// ── State ────────────────────────────────────────────────────────────────────

class EventState {
  const EventState({
    this.eventsByDay = const {},
    this.viewMode = 0,
    this.focusMonth,
    this.selectedDay,
    this.nextEventTime,
    this.nextEventTitle = '',
    this.timeUntilNext = Duration.zero,
  });

  final Map<int, List<Event>> eventsByDay;
  final int viewMode; // 0=List, 1=Calendar, 2=Map
  final DateTime? focusMonth;
  final int? selectedDay;
  final DateTime? nextEventTime;
  final String nextEventTitle;
  final Duration timeUntilNext;

  EventState copyWith({
    Map<int, List<Event>>? eventsByDay,
    int? viewMode,
    DateTime? focusMonth,
    int? selectedDay,
    bool clearSelectedDay = false,
    DateTime? nextEventTime,
    String? nextEventTitle,
    Duration? timeUntilNext,
  }) {
    return EventState(
      eventsByDay: eventsByDay ?? this.eventsByDay,
      viewMode: viewMode ?? this.viewMode,
      focusMonth: focusMonth ?? this.focusMonth,
      selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      nextEventTime: nextEventTime ?? this.nextEventTime,
      nextEventTitle: nextEventTitle ?? this.nextEventTitle,
      timeUntilNext: timeUntilNext ?? this.timeUntilNext,
    );
  }

  List<Event> get allEvents =>
      eventsByDay.values.expand((list) => list).toList();
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class EventNotifier extends StateNotifier<EventState> {
  EventNotifier(this._repo) : super(const EventState()) {
    _init();
  }
  final EventRepository _repo;
  Timer? _timer;

  void _init() {
    final events = _repo.getEventsByDay();
    final nextTime = _repo.nextEventTime;
    state = state.copyWith(
      eventsByDay: events,
      focusMonth: DateTime(2026, 2),
      nextEventTime: nextTime,
      nextEventTitle: _repo.nextEventTitle,
      timeUntilNext: nextTime.difference(DateTime.now()),
    );
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.nextEventTime == null) return;
      final diff = state.nextEventTime!.difference(DateTime.now());
      if (diff.isNegative) {
        _timer?.cancel();
        return;
      }
      state = state.copyWith(timeUntilNext: diff);
    });
  }

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final eventNotifierProvider =
    StateNotifierProvider<EventNotifier, EventState>((ref) {
  return EventNotifier(ref.watch(eventRepositoryProvider));
});
