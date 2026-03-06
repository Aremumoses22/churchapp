import 'dart:ui';
import 'package:flutter/widgets.dart';

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
}
