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

  static String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  static Color _colorFromId(String id) {
    const colors = [
      Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEF4444),
      Color(0xFF059669), Color(0xFFF59E0B), Color(0xFF0EA5E9),
      Color(0xFFEC4899), Color(0xFF6366F1),
    ];
    final hash = id.codeUnits.fold(0, (a, b) => a + b);
    return colors[hash % colors.length];
  }

  static String _relativeTime(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (_) {
      return '';
    }
  }

  factory ChatPreview.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'direct';
    final isGroup = type == 'group';
    final name = json['name'] as String? ?? '';
    final lastMsgJson = json['lastMessage'] as Map<String, dynamic>?;
    final lastContent = lastMsgJson?['content'] as String? ?? '';
    final lastSenderName =
        (lastMsgJson?['sender'] as Map<String, dynamic>?)?['name']
            as String? ??
            '';
    final lastMsg = isGroup && lastSenderName.isNotEmpty
        ? '$lastSenderName: $lastContent'
        : lastContent;
    return ChatPreview(
      id: json['id'] as String? ?? '',
      name: name,
      initials: _initials(name),
      avatarColor: _colorFromId(json['id'] as String? ?? ''),
      lastMessage: lastMsg,
      time: _relativeTime(json['lastMessageAt'] as String?),
      unreadCount: json['unreadCount'] as int? ?? 0,
      isOnline: false,
      isGroup: isGroup,
      isPinned: json['isPinned'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? false,
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

  static String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  static Color _colorFromId(String id) {
    const colors = [
      Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEF4444),
      Color(0xFF059669), Color(0xFFF59E0B), Color(0xFF0EA5E9),
      Color(0xFFEC4899), Color(0xFF6366F1),
    ];
    final hash = id.codeUnits.fold(0, (a, b) => a + b);
    return colors[hash % colors.length];
  }

  static String _formatTime(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final h = dt.hour > 12
          ? dt.hour - 12
          : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final p = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $p';
    } catch (_) {
      return '';
    }
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final senderJson = json['sender'] as Map<String, dynamic>?;
    final senderId = senderJson?['id'] as String? ?? '';
    final senderName = senderJson?['name'] as String? ?? '';
    final isMe = senderId.isNotEmpty && senderId == currentUserId;
    return ChatMessage(
      id: json['id'] as String? ?? '',
      text: json['content'] as String? ?? '',
      sender: senderName,
      senderInitials: isMe ? 'ME' : _initials(senderName),
      senderColor: isMe
          ? const Color(0xFF1E3A8A)
          : _colorFromId(senderId),
      time: _formatTime(json['createdAt'] as String?),
      isMe: isMe,
    );
  }
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
