import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SEARCH MODEL
// ──────────────────────────────────────────────────────────────────────────────

class SearchItem {
  const SearchItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
  final String route;

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] as String? ?? '').toLowerCase();
    final id = json['id'] as String? ?? '';
    return SearchItem(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ??
          json['description'] as String? ?? '',
      category: _categoryForType(type),
      icon: _iconForType(type),
      color: _colorForType(type),
      route: _routeForType(type, id),
    );
  }

  static String _categoryForType(String type) {
    switch (type) {
      case 'sermon':
      case 'series':
        return 'Sermons';
      case 'event':
        return 'Events';
      case 'user':
      case 'staff':
        return 'People';
      case 'forum':
      case 'thread':
        return 'Forum';
      case 'bible':
      case 'verse':
        return 'Bible';
      case 'group':
        return 'Groups';
      case 'giving':
      case 'campaign':
        return 'Giving';
      case 'media':
      case 'podcast':
      case 'music':
        return 'Media';
      default:
        return 'General';
    }
  }

  static IconData _iconForType(String type) {
    switch (type) {
      case 'sermon':
        return Icons.mic_outlined;
      case 'series':
        return Icons.playlist_play_outlined;
      case 'event':
        return Icons.event_outlined;
      case 'user':
      case 'staff':
        return Icons.person_outlined;
      case 'forum':
      case 'thread':
        return Icons.forum_outlined;
      case 'bible':
      case 'verse':
        return Icons.menu_book_outlined;
      case 'group':
        return Icons.groups_outlined;
      case 'giving':
      case 'campaign':
        return Icons.volunteer_activism_outlined;
      case 'media':
        return Icons.music_note_outlined;
      case 'podcast':
        return Icons.podcasts_outlined;
      default:
        return Icons.search_rounded;
    }
  }

  static Color _colorForType(String type) {
    switch (type) {
      case 'sermon':
      case 'series':
        return const Color(0xFF3B82F6);
      case 'event':
        return const Color(0xFFEF4444);
      case 'user':
      case 'staff':
        return const Color(0xFF8B5CF6);
      case 'forum':
      case 'thread':
        return const Color(0xFF6366F1);
      case 'bible':
      case 'verse':
        return const Color(0xFF059669);
      case 'group':
        return const Color(0xFFF59E0B);
      case 'giving':
      case 'campaign':
        return const Color(0xFFEC4899);
      case 'media':
      case 'podcast':
        return const Color(0xFF0EA5E9);
      default:
        return const Color(0xFF64748B);
    }
  }

  static String _routeForType(String type, String id) {
    switch (type) {
      case 'sermon':
        return '/sermons/$id';
      case 'series':
        return '/series/$id';
      case 'event':
        return '/events/$id';
      case 'user':
      case 'staff':
        return '/church-directory';
      case 'forum':
      case 'thread':
        return '/forum/thread/$id';
      case 'bible':
      case 'verse':
        return '/bible';
      case 'group':
        return '/connect-groups/$id';
      case 'giving':
      case 'campaign':
        return '/giving';
      default:
        return '/';
    }
  }
}
