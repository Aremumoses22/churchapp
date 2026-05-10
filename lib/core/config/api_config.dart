// ──────────────────────────────────────────────────────────────────────────────
// API CONFIGURATION
//
// Central place for base URL and endpoint paths.
// Matches the backend running at http://localhost:8080/api/v1.
// ──────────────────────────────────────────────────────────────────────────────

abstract final class ApiConfig {
  /// For iOS simulator: use localhost.
  /// For Android emulator: use 10.0.2.2 instead.
  static const String baseUrl = 'http://localhost:8080/api/v1';

  /// WebSocket URL (Socket.io).
  static const String wsUrl = 'ws://localhost:8080';

  /// Request timeout durations.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}

/// Centralised endpoint paths — no raw strings scattered in code.
abstract final class Endpoints {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String verifyEmail = '/auth/verify-email'; // + /:token
  static const String resendVerification = '/auth/resend-verification';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String verifyChurchCode = '/auth/verify-church-code';
  static const String completeSetup = '/auth/complete-setup';
  static const String logout = '/auth/logout';
  static const String deleteAccount = '/auth/account';

  // ── Users ─────────────────────────────────────────────────────────────────
  static const String userProfile = '/users/me';
  static const String userAvatar = '/users/me/avatar';
  static const String notificationPrefs = '/users/me/notification-prefs';
  static const String fcmToken = '/users/me/fcm-token';
  static const String attendance = '/users/me/attendance';
  static const String milestones = '/users/me/milestones';
  static const String savedItems = '/users/me/saved-items';
  /// DELETE /users/me/saved-items/:id
  static String savedItem(String id) => '/users/me/saved-items/$id';

  // ── Sermons ───────────────────────────────────────────────────────────────
  static const String sermons = '/sermons';
  static const String sermonsFeatured = '/sermons/featured';
  static const String sermonsSaved = '/sermons/saved';
  static const String sermonSeriesAll = '/sermons/series/all';
  /// GET /sermons/:id
  static String sermon(String id) => '/sermons/$id';
  /// GET /sermons/:id/stream
  static String sermonStream(String id) => '/sermons/$id/stream';
  /// POST /sermons/:id/progress
  static String sermonProgress(String id) => '/sermons/$id/progress';
  /// POST /sermons/:id/save (toggle bookmark)
  static String sermonSave(String id) => '/sermons/$id/save';
  /// GET / PUT /sermons/:id/notes
  static String sermonNotes(String id) => '/sermons/$id/notes';
  /// GET /sermons/series/:id
  static String sermonSeries(String id) => '/sermons/series/$id';

  // ── Events ────────────────────────────────────────────────────────────────
  static const String events = '/events';
  static const String eventsFeatured = '/events/featured';
  static const String eventsMy = '/events/my';
  /// GET /events/:id
  static String event(String id) => '/events/$id';
  /// POST / DELETE /events/:id/register
  static String eventRegister(String id) => '/events/$id/register';
}
