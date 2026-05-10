import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import 'auth_notifier.dart';

// ──────────────────────────────────────────────────────────────────────────────
// AUTH PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

/// Provides the [AuthRepository] singleton.
final authRepositoryProvider = Provider<AuthRepository>((_) {
  return AuthRepository();
});

/// The main auth state provider — UI reads this for loading/error/user.
final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthNotifierState>(AuthNotifier.new);

/// Quick access to [AuthService.state] for routing decisions.
final authStateProvider = Provider<AuthState>((ref) {
  return AuthService.instance.state;
});

/// Quick access to the current user profile (null if not logged in).
final currentUserProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authNotifierProvider).user;
});
