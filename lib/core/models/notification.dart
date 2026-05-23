import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────────────────────────
// NOTIFICATION MODELS
// ──────────────────────────────────────────────────────────────────────────────

enum NotificationType {
  live,
  event,
  prayer,
  sermon,
  giving,
  community,
  group,
  volunteer,
  general,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.group,
    this.actionLabel,
    this.isRead = false,
  });

  final String id;
  final NotificationType type;
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  final String group;
  final String? actionLabel;
  final bool isRead;

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    IconData? icon,
    Color? color,
    String? title,
    String? body,
    String? time,
    String? group,
    String? actionLabel,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      title: title ?? this.title,
      body: body ?? this.body,
      time: time ?? this.time,
      group: group ?? this.group,
      actionLabel: actionLabel ?? this.actionLabel,
      isRead: isRead ?? this.isRead,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String? ?? 'GENERAL').toUpperCase();
    final type = _typeFromString(typeStr);
    final createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now();

    return AppNotification(
      id: json['id'] as String,
      type: type,
      icon: _iconForType(type),
      color: _colorForType(type),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      time: _relativeTime(createdAt),
      group: _timeGroup(createdAt),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  static NotificationType _typeFromString(String s) {
    switch (s) {
      case 'LIVE_SERVICE':
      case 'LIVE':
        return NotificationType.live;
      case 'EVENT':
        return NotificationType.event;
      case 'PRAYER':
        return NotificationType.prayer;
      case 'SERMON':
        return NotificationType.sermon;
      case 'GIVING':
      case 'DONATION':
        return NotificationType.giving;
      case 'COMMUNITY':
      case 'FORUM':
      case 'ANNOUNCEMENT':
        return NotificationType.community;
      case 'GROUP':
        return NotificationType.group;
      case 'VOLUNTEER':
        return NotificationType.volunteer;
      default:
        return NotificationType.general;
    }
  }

  static IconData _iconForType(NotificationType t) {
    switch (t) {
      case NotificationType.live:
        return Icons.live_tv_rounded;
      case NotificationType.event:
        return Icons.event_outlined;
      case NotificationType.prayer:
        return Icons.favorite_rounded;
      case NotificationType.sermon:
        return Icons.headphones_outlined;
      case NotificationType.giving:
        return Icons.volunteer_activism_outlined;
      case NotificationType.community:
        return Icons.forum_outlined;
      case NotificationType.group:
        return Icons.groups_outlined;
      case NotificationType.volunteer:
        return Icons.handshake_outlined;
      case NotificationType.general:
        return Icons.campaign_outlined;
    }
  }

  static Color _colorForType(NotificationType t) {
    switch (t) {
      case NotificationType.live:
        return const Color(0xFFEF4444);
      case NotificationType.event:
        return const Color(0xFF6C63FF);
      case NotificationType.prayer:
        return const Color(0xFFEC4899);
      case NotificationType.sermon:
        return const Color(0xFF3B82F6);
      case NotificationType.giving:
        return const Color(0xFF059669);
      case NotificationType.community:
        return const Color(0xFF6366F1);
      case NotificationType.group:
        return const Color(0xFFF59E0B);
      case NotificationType.volunteer:
        return const Color(0xFF8B5CF6);
      case NotificationType.general:
        return const Color(0xFF64748B);
    }
  }

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  static String _timeGroup(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff <= 7) return 'This Week';
    return 'Earlier';
  }
}
