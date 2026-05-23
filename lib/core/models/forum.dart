import 'package:flutter/material.dart';

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

  static IconData _iconForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('prayer') || n.contains('worship')) {
      return Icons.volunteer_activism_outlined;
    }
    if (n.contains('bible') || n.contains('scripture')) {
      return Icons.menu_book_outlined;
    }
    if (n.contains('testim')) return Icons.stars_outlined;
    if (n.contains('youth')) return Icons.school_outlined;
    if (n.contains('event')) return Icons.event_outlined;
    if (n.contains('volunt') || n.contains('serve')) {
      return Icons.handshake_outlined;
    }
    if (n.contains('q') && n.contains('a')) return Icons.help_outline;
    return Icons.chat_bubble_outline;
  }

  static Color _colorForIndex(int index) {
    const colors = [
      Color(0xFFEF4444),
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFF059669),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF0EA5E9),
      Color(0xFF6366F1),
    ];
    return colors[index % colors.length];
  }

  factory ForumCategory.fromJson(Map<String, dynamic> json, {int index = 0}) {
    final name = json['name'] as String? ?? '';
    return ForumCategory(
      id: json['id'] as String? ?? '',
      label: name,
      icon: _iconForName(name),
      color: _colorForIndex(index),
      threadCount: json['threadCount'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );
  }
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
    this.isLiked = false,
    this.isBookmarked = false,
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
  final bool isLiked;
  final bool isBookmarked;

  ForumThread copyWith({
    int? likes,
    int? replies,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return ForumThread(
      id: id,
      title: title,
      author: author,
      authorInitials: authorInitials,
      avatarColor: avatarColor,
      body: body,
      replies: replies ?? this.replies,
      likes: likes ?? this.likes,
      timeAgo: timeAgo,
      category: category,
      categoryColor: categoryColor,
      isPinned: isPinned,
      isLocked: isLocked,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  static Color _colorFromId(String id) {
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFFEF4444),
      Color(0xFF059669),
      Color(0xFFF59E0B),
      Color(0xFF0EA5E9),
      Color(0xFFEC4899),
    ];
    final hash = id.codeUnits.fold(0, (a, b) => a + b);
    return colors[hash % colors.length];
  }

  static String _relativeTime(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (_) {
      return '';
    }
  }

  factory ForumThread.fromJson(Map<String, dynamic> json) {
    final authorJson = json['author'] as Map<String, dynamic>?;
    final authorName = authorJson?['name'] as String? ?? '';
    final categoryJson = json['category'] as Map<String, dynamic>?;
    return ForumThread(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: authorName,
      authorInitials: _initials(authorName),
      avatarColor: _colorFromId(json['id'] as String? ?? ''),
      body: json['content'] as String? ?? '',
      replies: json['replyCount'] as int? ?? 0,
      likes: json['likeCount'] as int? ?? 0,
      timeAgo: _relativeTime(json['createdAt'] as String?),
      category: categoryJson?['name'] as String? ?? '',
      categoryColor: const Color(0xFF64748B),
      isPinned: json['isPinned'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }
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
    this.id = '',
    this.replyCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  final String id;
  final String title;
  final String author;
  final String authorInitials;
  final Color avatarColor;
  final String body;
  final String category;
  final Color categoryColor;
  final String timeAgo;
  final int views;
  final int replyCount;
  final int likeCount;
  final bool isLiked;
  final bool isBookmarked;

  ForumPost copyWith({int? likeCount, bool? isLiked, bool? isBookmarked}) {
    return ForumPost(
      id: id,
      title: title,
      author: author,
      authorInitials: authorInitials,
      avatarColor: avatarColor,
      body: body,
      category: category,
      categoryColor: categoryColor,
      timeAgo: timeAgo,
      views: views,
      replyCount: replyCount,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    final authorJson = json['author'] as Map<String, dynamic>?;
    final authorName = authorJson?['name'] as String? ?? '';
    final categoryJson = json['category'] as Map<String, dynamic>?;
    final id = json['id'] as String? ?? '';
    return ForumPost(
      id: id,
      title: json['title'] as String? ?? '',
      author: authorName,
      authorInitials: ForumThread._initials(authorName),
      avatarColor: ForumThread._colorFromId(id),
      body: json['content'] as String? ?? '',
      category: categoryJson?['name'] as String? ?? '',
      categoryColor: const Color(0xFF64748B),
      timeAgo: ForumThread._relativeTime(json['createdAt'] as String?),
      views: json['viewCount'] as int? ?? 0,
      replyCount: json['replyCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }
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

  factory ForumReply.fromJson(Map<String, dynamic> json) {
    final authorJson = json['sender'] as Map<String, dynamic>? ??
        json['author'] as Map<String, dynamic>?;
    final authorName = authorJson?['name'] as String? ?? '';
    final id = json['id'] as String? ?? '';
    return ForumReply(
      id: id,
      author: authorName,
      authorInitials: ForumThread._initials(authorName),
      avatarColor: ForumThread._colorFromId(id),
      body: json['content'] as String? ?? '',
      timeAgo: ForumThread._relativeTime(json['createdAt'] as String?),
      likes: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }
}

// Combined response from GET /forum/threads/:id
// The backend returns { thread: {...}, replies: { data: [...], meta: {...} } }
class ForumThreadDetail {
  const ForumThreadDetail({required this.post, required this.replies});

  final ForumPost post;
  final List<ForumReply> replies;

  factory ForumThreadDetail.fromJson(Map<String, dynamic> json) {
    final threadJson = json['thread'] as Map<String, dynamic>?;
    final repliesJson =
        (json['replies'] as Map<String, dynamic>?)?['data'] as List<dynamic>?;

    return ForumThreadDetail(
      post: threadJson != null
          ? ForumPost.fromJson(threadJson)
          : const ForumPost(
              title: '',
              author: '',
              authorInitials: '?',
              avatarColor: Color(0xFF64748B),
              body: '',
              category: '',
              categoryColor: Color(0xFF64748B),
              timeAgo: '',
              views: 0,
            ),
      replies: repliesJson
              ?.map((r) => ForumReply.fromJson(r as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
