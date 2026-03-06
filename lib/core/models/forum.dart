import 'dart:ui';
import 'package:flutter/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// FORUM MODELS
// ──────────────────────────────────────────────────────────────────────────────

class ForumCategory {
  const ForumCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.threadCount,
    required this.description,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final int threadCount;
  final String description;
}

class ForumThread {
  const ForumThread({
    required this.id,
    required this.title,
    required this.author,
    required this.authorInitials,
    required this.avatarColor,
    required this.body,
    required this.replies,
    required this.likes,
    required this.timeAgo,
    this.category = '',
    this.categoryColor = const Color(0xFF64748B),
    this.isPinned = false,
    this.isLocked = false,
  });

  final String id;
  final String title;
  final String author;
  final String authorInitials;
  final Color avatarColor;
  final String body;
  final int replies;
  final int likes;
  final String timeAgo;
  final String category;
  final Color categoryColor;
  final bool isPinned;
  final bool isLocked;
}

class ForumPost {
  const ForumPost({
    required this.title,
    required this.author,
    required this.authorInitials,
    required this.avatarColor,
    required this.body,
    required this.category,
    required this.categoryColor,
    required this.timeAgo,
    required this.views,
  });

  final String title;
  final String author;
  final String authorInitials;
  final Color avatarColor;
  final String body;
  final String category;
  final Color categoryColor;
  final String timeAgo;
  final int views;
}

class ForumReply {
  const ForumReply({
    required this.id,
    required this.author,
    required this.authorInitials,
    required this.avatarColor,
    required this.body,
    required this.timeAgo,
    required this.likes,
    this.isLiked = false,
  });

  final String id;
  final String author;
  final String authorInitials;
  final Color avatarColor;
  final String body;
  final String timeAgo;
  final int likes;
  final bool isLiked;

  ForumReply copyWith({
    String? id,
    String? author,
    String? authorInitials,
    Color? avatarColor,
    String? body,
    String? timeAgo,
    int? likes,
    bool? isLiked,
  }) {
    return ForumReply(
      id: id ?? this.id,
      author: author ?? this.author,
      authorInitials: authorInitials ?? this.authorInitials,
      avatarColor: avatarColor ?? this.avatarColor,
      body: body ?? this.body,
      timeAgo: timeAgo ?? this.timeAgo,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
