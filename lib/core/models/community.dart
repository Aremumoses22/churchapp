import 'dart:ui';

// ──────────────────────────────────────────────────────────────────────────────
// CONNECT GROUP MODEL
// ──────────────────────────────────────────────────────────────────────────────

class ConnectGroup {
  const ConnectGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.memberCount,
    required this.maxMembers,
    required this.meetingDay,
    required this.meetingTime,
    required this.location,
    required this.leader,
    required this.color,
    required this.isOpen,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final int memberCount;
  final int maxMembers;
  final String meetingDay;
  final String meetingTime;
  final String location;
  final String leader;
  final Color color;
  final bool isOpen;
}
