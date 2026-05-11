import 'dart:ui';

// ──────────────────────────────────────────────────────────────────────────────
// COMMUNITY MODELS
// ──────────────────────────────────────────────────────────────────────────────

// ── Connect Group ─────────────────────────────────────────────────────────────

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
    this.imageUrl,
    this.isMember = false,
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
  final String? imageUrl;
  final bool isMember;

  ConnectGroup copyWith({bool? isMember}) {
    return ConnectGroup(
      id: id,
      name: name,
      description: description,
      category: category,
      memberCount: memberCount,
      maxMembers: maxMembers,
      meetingDay: meetingDay,
      meetingTime: meetingTime,
      location: location,
      leader: leader,
      color: color,
      isOpen: isOpen,
      imageUrl: imageUrl,
      isMember: isMember ?? this.isMember,
    );
  }

  static Color _colorForCategory(String category) {
    const map = {
      'BIBLE_STUDY': Color(0xFF059669),
      'YOUTH': Color(0xFFEA580C),
      'WOMEN': Color(0xFF7C3AED),
      'MEN': Color(0xFF1E40AF),
      'COUPLES': Color(0xFFDC2626),
      'PRAYER': Color(0xFF0891B2),
      'SERVICE': Color(0xFFB45309),
      'OTHER': Color(0xFF64748B),
    };
    return map[category.toUpperCase()] ?? const Color(0xFF64748B);
  }

  factory ConnectGroup.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as String? ?? 'OTHER';
    final leaderJson = json['leader'] as Map<String, dynamic>?;
    return ConnectGroup(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: category,
      memberCount: json['memberCount'] as int? ?? 0,
      maxMembers: json['maxMembers'] as int? ?? 0,
      meetingDay: json['meetingDay'] as String? ?? '',
      meetingTime: json['meetingTime'] as String? ?? '',
      location: json['location'] as String? ?? '',
      leader: leaderJson?['name'] as String? ?? '',
      color: _colorForCategory(category),
      isOpen: (json['memberCount'] as int? ?? 0) <
          (json['maxMembers'] as int? ?? 1),
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class GroupDetail extends ConnectGroup {
  const GroupDetail({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.memberCount,
    required super.maxMembers,
    required super.meetingDay,
    required super.meetingTime,
    required super.location,
    required super.leader,
    required super.color,
    required super.isOpen,
    super.imageUrl,
    super.isMember,
    this.members = const [],
  });

  final List<GroupMember> members;

  factory GroupDetail.fromJson(Map<String, dynamic> json) {
    final base = ConnectGroup.fromJson(json);
    return GroupDetail(
      id: base.id,
      name: base.name,
      description: base.description,
      category: base.category,
      memberCount: base.memberCount,
      maxMembers: base.maxMembers,
      meetingDay: base.meetingDay,
      meetingTime: base.meetingTime,
      location: base.location,
      leader: base.leader,
      color: base.color,
      isOpen: base.isOpen,
      imageUrl: base.imageUrl,
      isMember: base.isMember,
      members: (json['members'] as List?)
              ?.map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class GroupMember {
  const GroupMember({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.role,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String? role;

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String?,
    );
  }
}

// ── Announcement ──────────────────────────────────────────────────────────────

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.category,
    this.isUrgent = false,
    this.isPinned = false,
    this.publishedAt,
    this.expiresAt,
    this.authorName,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? category;
  final bool isUrgent;
  final bool isPinned;
  final String? publishedAt;
  final String? expiresAt;
  final String? authorName;
  final bool isRead;

  Announcement copyWith({bool? isRead}) {
    return Announcement(
      id: id,
      title: title,
      content: content,
      imageUrl: imageUrl,
      category: category,
      isUrgent: isUrgent,
      isPinned: isPinned,
      publishedAt: publishedAt,
      expiresAt: expiresAt,
      authorName: authorName,
      isRead: isRead ?? this.isRead,
    );
  }

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      isUrgent: json['isUrgent'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      publishedAt: json['publishedAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      authorName: (json['author'] as Map<String, dynamic>?)?['name'] as String?,
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

// ── Testimony ─────────────────────────────────────────────────────────────────

class Testimony {
  const Testimony({
    required this.id,
    required this.title,
    required this.content,
    this.authorName,
    this.authorAvatarUrl,
    this.isAnonymous = false,
    this.status,
    this.likeCount = 0,
    this.prayCount = 0,
    this.hasLiked = false,
    this.hasPrayed = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final String? authorName;
  final String? authorAvatarUrl;
  final bool isAnonymous;
  final String? status;
  final int likeCount;
  final int prayCount;
  final bool hasLiked;
  final bool hasPrayed;
  final String? createdAt;

  Testimony copyWith({
    int? likeCount,
    int? prayCount,
    bool? hasLiked,
    bool? hasPrayed,
  }) {
    return Testimony(
      id: id,
      title: title,
      content: content,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      isAnonymous: isAnonymous,
      status: status,
      likeCount: likeCount ?? this.likeCount,
      prayCount: prayCount ?? this.prayCount,
      hasLiked: hasLiked ?? this.hasLiked,
      hasPrayed: hasPrayed ?? this.hasPrayed,
      createdAt: createdAt,
    );
  }

  factory Testimony.fromJson(Map<String, dynamic> json) {
    return Testimony(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorName: (json['author'] as Map<String, dynamic>?)?['name'] as String?,
      authorAvatarUrl:
          (json['author'] as Map<String, dynamic>?)?['avatarUrl'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      status: json['status'] as String?,
      likeCount: json['likeCount'] as int? ?? 0,
      prayCount: json['prayCount'] as int? ?? 0,
      hasLiked: json['hasLiked'] as bool? ?? false,
      hasPrayed: json['hasPrayed'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
    );
  }
}

// ── Directory Member ──────────────────────────────────────────────────────────

class DirectoryMember {
  const DirectoryMember({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.department,
    this.joinedDate,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String? department;
  final String? joinedDate;

  factory DirectoryMember.fromJson(Map<String, dynamic> json) {
    return DirectoryMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      department: json['department'] as String?,
      joinedDate: json['joinedDate'] as String?,
    );
  }
}

// ── Invite ────────────────────────────────────────────────────────────────────

class InviteInfo {
  const InviteInfo({
    required this.code,
    required this.link,
    this.expiresAt,
  });

  final String code;
  final String link;
  final String? expiresAt;

  factory InviteInfo.fromJson(Map<String, dynamic> json) {
    return InviteInfo(
      code: json['code'] as String? ?? '',
      link: json['link'] as String? ?? '',
      expiresAt: json['expiresAt'] as String?,
    );
  }
}

class InviteStats {
  const InviteStats({
    this.totalInvites = 0,
    this.totalUsed = 0,
  });

  final int totalInvites;
  final int totalUsed;

  factory InviteStats.fromJson(Map<String, dynamic> json) {
    return InviteStats(
      totalInvites: json['totalInvites'] as int? ?? 0,
      totalUsed: json['totalUsed'] as int? ?? 0,
    );
  }
}
