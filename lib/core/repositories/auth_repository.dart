import '../models/user.dart';
import '../services/auth_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// AUTH REPOSITORY
// ──────────────────────────────────────────────────────────────────────────────

abstract class AuthRepository {
  AuthState get state;
  UserProfile? get currentUser;
  Future<void> login({String? email, String? name});
  Future<void> logout();
  Future<void> completeOnboarding();
  Future<void> completeSetup();
  Future<void> clearAll();
}

/// Wraps the existing [AuthService] singleton behind an abstract interface
/// so screens can access auth through Riverpod providers.
class AppAuthRepository implements AuthRepository {
  AppAuthRepository(this._service);
  final AuthService _service;

  @override
  AuthState get state => _service.state;

  @override
  UserProfile? get currentUser {
    if (_service.userName == null && _service.userEmail == null) return null;
    return UserProfile(
      name: _service.userName ?? 'User',
      email: _service.userEmail ?? '',
    );
  }

  @override
  Future<void> login({String? email, String? name}) =>
      _service.login(email: email, name: name);

  @override
  Future<void> logout() => _service.logout();

  @override
  Future<void> completeOnboarding() => _service.completeOnboarding();

  @override
  Future<void> completeSetup() => _service.completeSetup();

  @override
  Future<void> clearAll() => _service.clearAll();
}
