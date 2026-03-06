import 'dart:ui';

import '../models/community.dart';

// ──────────────────────────────────────────────────────────────────────────────
// COMMUNITY REPOSITORY
// ──────────────────────────────────────────────────────────────────────────────

abstract class CommunityRepository {
  List<ConnectGroup> getGroups();
  List<String> getCategories();
}

class MockCommunityRepository implements CommunityRepository {
  @override
  List<String> getCategories() => const [
        'All', 'Men', 'Women', 'Youth', 'Couples',
        'Bible Study', 'Prayer', 'Service',
      ];

  @override
  List<ConnectGroup> getGroups() => const [
        ConnectGroup(
          id: '1',
          name: "Men's Fellowship",
          description:
              'A brotherhood of men pursuing faith, accountability, and purpose together.',
          category: 'Men',
          memberCount: 24,
          maxMembers: 30,
          meetingDay: 'Saturdays',
          meetingTime: '8:00 AM',
          location: 'Room 201',
          leader: 'Marcus Johnson',
          color: Color(0xFF1E40AF),
          isOpen: true,
        ),
        ConnectGroup(
          id: '2',
          name: "Women's Bible Study",
          description:
              'Diving deep into Scripture together, growing in faith and fellowship.',
          category: 'Women',
          memberCount: 18,
          maxMembers: 20,
          meetingDay: 'Tuesdays',
          meetingTime: '10:00 AM',
          location: 'Chapel',
          leader: 'Rachel Adams',
          color: Color(0xFF7C3AED),
          isOpen: true,
        ),
        ConnectGroup(
          id: '3',
          name: 'Youth Impact',
          description:
              'High-energy gatherings for teens with worship, games, and real talk about faith.',
          category: 'Youth',
          memberCount: 35,
          maxMembers: 50,
          meetingDay: 'Fridays',
          meetingTime: '7:00 PM',
          location: 'Youth Center',
          leader: 'Jake Torres',
          color: Color(0xFFEA580C),
          isOpen: true,
        ),
        ConnectGroup(
          id: '4',
          name: 'Couples Connect',
          description:
              'Strengthen your marriage through shared devotion, conversation, and community.',
          category: 'Couples',
          memberCount: 12,
          maxMembers: 14,
          meetingDay: 'Wednesdays',
          meetingTime: '7:00 PM',
          location: 'Room 105',
          leader: 'David & Sarah Kim',
          color: Color(0xFFDC2626),
          isOpen: true,
        ),
        ConnectGroup(
          id: '5',
          name: 'Gospel of John Study',
          description:
              'A verse-by-verse journey through the Gospel of John over 12 weeks.',
          category: 'Bible Study',
          memberCount: 15,
          maxMembers: 15,
          meetingDay: 'Thursdays',
          meetingTime: '6:30 PM',
          location: 'Library',
          leader: 'Pastor Stephen Cole',
          color: Color(0xFF059669),
          isOpen: false,
        ),
        ConnectGroup(
          id: '6',
          name: 'Intercessory Prayer',
          description:
              'A dedicated group of prayer warriors lifting up the church and community.',
          category: 'Prayer',
          memberCount: 10,
          maxMembers: 20,
          meetingDay: 'Mondays',
          meetingTime: '6:00 AM',
          location: 'Prayer Room',
          leader: 'Grace Okafor',
          color: Color(0xFF0891B2),
          isOpen: true,
        ),
        ConnectGroup(
          id: '7',
          name: 'Community Outreach',
          description:
              'Serving our local community through food drives, tutoring, and neighborhood projects.',
          category: 'Service',
          memberCount: 28,
          maxMembers: 40,
          meetingDay: 'Saturdays',
          meetingTime: '9:00 AM',
          location: 'Fellowship Hall',
          leader: 'Tom Bradley',
          color: Color(0xFFB45309),
          isOpen: true,
        ),
      ];
}
