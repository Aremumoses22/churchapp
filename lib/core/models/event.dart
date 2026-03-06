import 'dart:ui';

// ──────────────────────────────────────────────────────────────────────────────
// EVENT MODEL
// ──────────────────────────────────────────────────────────────────────────────

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.imageColor,
    required this.attendees,
    this.isRecurring = false,
    this.pastPhotos = const [],
  });

  final String id;
  final String title;
  final String date;
  final String location;
  final Color imageColor;
  final int attendees;
  final bool isRecurring;
  final List<Color> pastPhotos;
}
