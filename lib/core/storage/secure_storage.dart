import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyUserRole = 'user_role';

  // ── Tokens
  static Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);

  static Future<String?> getAccessToken() =>
      _storage.read(key: _keyAccessToken);

  static Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _keyRefreshToken);

  static Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  // ── User Meta
  static Future<void> saveUserId(String id) =>
      _storage.write(key: _keyUserId, value: id);

  static Future<String?> getUserId() => _storage.read(key: _keyUserId);

  static Future<void> saveUserRole(String role) =>
      _storage.write(key: _keyUserRole, value: role);

  static Future<String?> getUserRole() => _storage.read(key: _keyUserRole);

  // ── Full clear on logout
  static Future<void> clearAll() => _storage.deleteAll();

  // ── Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
