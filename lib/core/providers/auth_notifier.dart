// ──────────────────────────────────────────────────────────────────────────────
// AUTH NOTIFIER
//
// Riverpod AsyncNotifier managing the full auth lifecycle.
// Bridges AuthRepository (API calls) and AuthService (local state).
//
// The UI reads `authNotifierProvider` for loading/error/data states, and
// calls methods like `login()`, `register()`, etc.
// ──────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import 'auth_providers.dart';

/// Auth state exposed to the UI.
class AuthNotifierState {
  const AuthNotifierState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  final UserProfile? user;
  final bool isLoading;
  final String? error;

  AuthNotifierState copyWith({
    UserProfile? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthNotifierState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends Notifier<AuthNotifierState> {
  late final AuthRepository _repo;
  final AuthService _authService = AuthService.instance;

  @override
  AuthNotifierState build() {
    _repo = ref.watch(authRepositoryProvider);
    return const AuthNotifierState();
  }

  // ── Register ──────────────────────────────────────────────────────────

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _repo.register(
      RegisterRequest(name: name, email: email, password: password),
    );

    if (response.success) {
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: response.errorSummary);
      return false;
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _repo.login(
      LoginRequest(email: email, password: password),
    );

    if (response.success && response.data != null) {
      final loginData = response.data!;
      final user = loginData.user;

      // Persist auth state locally.
      await _authService.login(
        email: user.email,
        name: user.name,
        userId: user.id,
        churchId: user.churchId,
        hasCompletedSetup: user.hasCompletedSetup,
      );

      state = state.copyWith(isLoading: false, user: user);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: response.errorSummary);
      return false;
    }
  }

  // ── Resend Verification ───────────────────────────────────────────────

  Future<bool> resendVerification(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repo.resendVerification(email);
    state = state.copyWith(isLoading: false);
    if (!response.success) {
      state = state.copyWith(error: response.errorSummary);
    }
    return response.success;
  }

  // ── Forgot Password ───────────────────────────────────────────────────

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repo.forgotPassword(email);
    state = state.copyWith(isLoading: false);
    if (!response.success) {
      state = state.copyWith(error: response.errorSummary);
    }
    return response.success;
  }

  // ── Reset Password ────────────────────────────────────────────────────

  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repo.resetPassword(
      ResetPasswordRequest(token: token, password: password),
    );
    state = state.copyWith(isLoading: false);
    if (!response.success) {
      state = state.copyWith(error: response.errorSummary);
    }
    return response.success;
  }

  // ── Verify Church Code ────────────────────────────────────────────────

  Future<bool> verifyChurchCode(String code) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repo.verifyChurchCode(code);
    if (response.success) {
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: response.errorSummary);
      return false;
    }
  }

  // ── Complete Setup ────────────────────────────────────────────────────

  Future<bool> completeSetup({
    required String name,
    String? bio,
    String? department,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repo.completeSetup(
      CompleteSetupRequest(name: name, bio: bio, department: department),
    );
    if (response.success) {
      await _authService.completeSetup();
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: response.errorSummary);
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _repo.logout();
    await _authService.logout();
    state = const AuthNotifierState();
  }

  // ── Delete Account ────────────────────────────────────────────────────

  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repo.deleteAccount();
    if (response.success) {
      await _authService.logout();
      state = const AuthNotifierState();
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: response.errorSummary);
      return false;
    }
  }

  // ── Fetch Profile ─────────────────────────────────────────────────────

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repo.getProfile();
    if (response.success && response.data != null) {
      state = state.copyWith(isLoading: false, user: response.data);
    } else {
      state = state.copyWith(isLoading: false, error: response.errorSummary);
    }
  }

  // ── Clear Error ───────────────────────────────────────────────────────

  void clearError() => state = state.copyWith(clearError: true);
}
