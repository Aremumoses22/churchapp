// ──────────────────────────────────────────────────────────────────────────────
// USER PROFILE MODEL
// ──────────────────────────────────────────────────────────────────────────────

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final String name;
  final String email;
  final String? photoUrl;

  UserProfile copyWith({
    String? name,
    String? email,
    String? photoUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
