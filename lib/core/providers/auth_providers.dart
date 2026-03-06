import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// AUTH PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((_) {
  return AppAuthRepository(AuthService.instance);
});

final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).state;
});

final currentUserProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser;
});
