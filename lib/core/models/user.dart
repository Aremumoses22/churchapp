// ──────────────────────────────────────────────────────────────────────────────
// USER PROFILE MODEL
//
// Full user profile as returned by GET /users/me and POST /auth/login.
// See API_INTEGRATION_GUIDE.md § 3 & 4.
// ──────────────────────────────────────────────────────────────────────────────

/// User roles matching the backend enum.
enum UserRole {
  member,
  leader,
  pastor,
  admin,
  superAdmin;

  static UserRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LEADER':
        return UserRole.leader;
      case 'PASTOR':
        return UserRole.pastor;
      case 'ADMIN':
        return UserRole.admin;
      case 'SUPER_ADMIN':
        return UserRole.superAdmin;
      default:
        return UserRole.member;
    }
  }

  String toJson() {
    switch (this) {
      case UserRole.superAdmin:
        return 'SUPER_ADMIN';
      default:
        return name.toUpperCase();
    }
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.churchId,
    this.phone,
    this.bio,
    this.avatarUrl,
    this.department,
    this.joinedDate,
    this.isActive = true,
    this.isDirectoryVisible = true,
    this.hasCompletedSetup = false,
    this.notificationPrefs,
    this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? churchId;
  final String? phone;
  final String? bio;
  final String? avatarUrl;
  final String? department;
  final String? joinedDate;
  final bool isActive;
  final bool isDirectoryVisible;
  final bool hasCompletedSetup;
  final Map<String, bool>? notificationPrefs;
  final DateTime? createdAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String? ?? 'MEMBER'),
      churchId: json['churchId'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      department: json['department'] as String?,
      joinedDate: json['joinedDate'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isDirectoryVisible: json['isDirectoryVisible'] as bool? ?? true,
      hasCompletedSetup: json['hasCompletedSetup'] as bool? ?? false,
      notificationPrefs: json['notificationPrefs'] != null
          ? (json['notificationPrefs'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v as bool? ?? false))
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role.toJson(),
        'churchId': churchId,
        'phone': phone,
        'bio': bio,
        'avatarUrl': avatarUrl,
        'department': department,
        'hasCompletedSetup': hasCompletedSetup,
      };

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? churchId,
    String? phone,
    String? bio,
    String? avatarUrl,
    String? department,
    String? joinedDate,
    bool? isActive,
    bool? isDirectoryVisible,
    bool? hasCompletedSetup,
    Map<String, bool>? notificationPrefs,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      churchId: churchId ?? this.churchId,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      department: department ?? this.department,
      joinedDate: joinedDate ?? this.joinedDate,
      isActive: isActive ?? this.isActive,
      isDirectoryVisible: isDirectoryVisible ?? this.isDirectoryVisible,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
      notificationPrefs: notificationPrefs ?? this.notificationPrefs,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
