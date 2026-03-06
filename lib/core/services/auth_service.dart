import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ──────────────────────────────────────────────────────────────────────────────
// AUTH SERVICE
//
// Lightweight auth state manager backed by SharedPreferences.
//
// Tracks three persistent flags:
//   • hasSeenOnboarding — skip the 3-slide intro on subsequent opens.
//   • isLoggedIn        — user has an active session.
//   • hasCompletedSetup — user finished the church-code step.
//
// Provides a ValueNotifier<AuthState> so any widget can react to changes.
// ──────────────────────────────────────────────────────────────────────────────

/// Possible auth/lifecycle states of the app.
enum AuthState {
  /// Initial state while SharedPreferences are loading.
  unknown,

  /// First-ever launch — user has never seen onboarding.
  firstLaunch,

  /// User saw onboarding but is not logged in.
  unauthenticated,

  /// User logged in but hasn't entered a church code yet.
  needsSetup,

  /// Fully authenticated and set up — go to /home.
  authenticated,
}

class AuthService extends ChangeNotifier {
  AuthService._();

  static final AuthService instance = AuthService._();

  // ── SharedPreferences keys ─────────────────────────────────────────────
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keySetupComplete = 'setup_complete';
  static const _keyUserEmail = 'user_email';
  static const _keyUserName = 'user_name';

  SharedPreferences? _prefs;

  // ── Derived state ──────────────────────────────────────────────────────
  AuthState _state = AuthState.unknown;
  AuthState get state => _state;

  bool get hasSeenOnboarding => _prefs?.getBool(_keyOnboardingSeen) ?? false;
  bool get isLoggedIn => _prefs?.getBool(_keyIsLoggedIn) ?? false;
  bool get hasCompletedSetup => _prefs?.getBool(_keySetupComplete) ?? false;
  String? get userEmail => _prefs?.getString(_keyUserEmail);
  String? get userName => _prefs?.getString(_keyUserName);

  // ── Initialise ─────────────────────────────────────────────────────────
  /// Must be called once at app start (before runApp or inside main).
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _resolveState();
    notifyListeners();
  }

  void _resolveState() {
    if (!hasSeenOnboarding) {
      _state = AuthState.firstLaunch;
    } else if (!isLoggedIn) {
      _state = AuthState.unauthenticated;
    } else if (!hasCompletedSetup) {
      _state = AuthState.needsSetup;
    } else {
      _state = AuthState.authenticated;
    }
  }

  // ── Mutations ──────────────────────────────────────────────────────────

  /// Mark the onboarding flow as completed.
  Future<void> completeOnboarding() async {
    await _prefs?.setBool(_keyOnboardingSeen, true);
    _resolveState();
    notifyListeners();
  }

  /// Mark user as logged in and store basic profile info.
  Future<void> login({String? email, String? name}) async {
    await _prefs?.setBool(_keyIsLoggedIn, true);
    if (email != null) await _prefs?.setString(_keyUserEmail, email);
    if (name != null) await _prefs?.setString(_keyUserName, name);
    _resolveState();
    notifyListeners();
  }

  /// Mark the church-code / profile setup step as done.
  Future<void> completeSetup() async {
    await _prefs?.setBool(_keySetupComplete, true);
    _resolveState();
    notifyListeners();
  }

  /// Full sign-out — clears login & setup flags (keeps onboarding flag).
  Future<void> logout() async {
    await _prefs?.setBool(_keyIsLoggedIn, false);
    await _prefs?.setBool(_keySetupComplete, false);
    await _prefs?.remove(_keyUserEmail);
    await _prefs?.remove(_keyUserName);
    _resolveState();
    notifyListeners();
  }

  /// Nuclear reset — removes every persisted key (useful for testing).
  Future<void> clearAll() async {
    await _prefs?.clear();
    _state = AuthState.firstLaunch;
    notifyListeners();
  }
}
