// ──────────────────────────────────────────────────────────────────────────────
// SECURE TOKEN STORAGE
//
// Persists JWT tokens in the platform keychain / keystore via
// flutter_secure_storage. Used by the API client & auth service.
// ──────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Access Token ─────────────────────────────────────────────────────────
  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);
  Future<void> setAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);
  Future<void> deleteAccessToken() => _storage.delete(key: _keyAccessToken);

  // ── Refresh Token ────────────────────────────────────────────────────────
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);
  Future<void> setRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);
  Future<void> deleteRefreshToken() => _storage.delete(key: _keyRefreshToken);

  // ── Convenience ──────────────────────────────────────────────────────────
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      setAccessToken(accessToken),
      setRefreshToken(refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      deleteAccessToken(),
      deleteRefreshToken(),
    ]);
  }

  Future<bool> hasTokens() async {
    final access = await getAccessToken();
    return access != null && access.isNotEmpty;
  }
}
