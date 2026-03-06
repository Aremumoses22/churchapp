import 'dart:ui';

import '../models/event.dart';
import '../theme/app_colors.dart';

// ──────────────────────────────────────────────────────────────────────────────
// EVENT REPOSITORY
// ──────────────────────────────────────────────────────────────────────────────

abstract class EventRepository {
  Map<int, List<Event>> getEventsByDay();
  DateTime get nextEventTime;
  String get nextEventTitle;
}

class MockEventRepository implements EventRepository {
  @override
  DateTime get nextEventTime => DateTime(2026, 2, 25, 10, 0);

  @override
  String get nextEventTitle => 'Worship Conference 2026';

  @override
  Map<int, List<Event>> getEventsByDay() => {
        8: [
          Event(
            id: '1',
            title: 'Youth Night',
            date: 'Sat, Feb 8 · 6:00 PM',
            location: 'Main Auditorium',
            imageColor: AppColors.primary,
            attendees: 47,
            isRecurring: true,
            pastPhotos: const [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFA78BFA),
            ],
          ),
        ],
        14: [
          Event(
            id: '2',
            title: 'Valentine Couples Dinner',
            date: 'Sat, Feb 14 · 7:00 PM',
            location: 'Fellowship Hall',
            imageColor: AppColors.gold,
            attendees: 92,
          ),
        ],
        25: [
          Event(
            id: '3',
            title: 'Worship Conference 2026',
            date: 'Wed, Feb 25 · 10:00 AM',
            location: 'Grace Cathedral',
            imageColor: AppColors.primary,
            attendees: 215,
            isRecurring: true,
            pastPhotos: const [
              Color(0xFF1E40AF),
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
              Color(0xFF93C5FD),
            ],
          ),
          Event(
            id: '4',
            title: 'Community Outreach',
            date: 'Wed, Feb 25 · 2:00 PM',
            location: 'City Park',
            imageColor: AppColors.success,
            attendees: 34,
            isRecurring: true,
            pastPhotos: const [
              Color(0xFF059669),
              Color(0xFF34D399),
              Color(0xFF6EE7B7),
            ],
          ),
        ],
      };
}
