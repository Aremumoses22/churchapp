import 'dart:ui';

// ──────────────────────────────────────────────────────────────────────────────
// CHAT MODELS
// ──────────────────────────────────────────────────────────────────────────────

class ChatPreview {
  const ChatPreview({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isGroup = false,
    this.isPinned = false,
    this.isMuted = false,
  });

  final String id;
  final String name;
  final String initials;
  final Color avatarColor;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isGroup;
  final bool isPinned;
  final bool isMuted;

  ChatPreview copyWith({
    String? id,
    String? name,
    String? initials,
    Color? avatarColor,
    String? lastMessage,
    String? time,
    int? unreadCount,
    bool? isOnline,
    bool? isGroup,
    bool? isPinned,
    bool? isMuted,
  }) {
    return ChatPreview(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      avatarColor: avatarColor ?? this.avatarColor,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isGroup: isGroup ?? this.isGroup,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.senderInitials,
    required this.senderColor,
    required this.time,
    required this.isMe,
    this.timeGroup = '',
  });

  final String id;
  final String text;
  final String sender;
  final String senderInitials;
  final Color senderColor;
  final String time;
  final bool isMe;
  final String timeGroup;
}

class ChatMeta {
  const ChatMeta({
    required this.name,
    required this.initials,
    required this.color,
    required this.isOnline,
    this.isGroup = false,
    this.memberCount = 0,
  });

  final String name;
  final String initials;
  final Color color;
  final bool isOnline;
  final bool isGroup;
  final int memberCount;
}
