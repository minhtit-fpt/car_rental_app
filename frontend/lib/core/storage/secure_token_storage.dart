import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lưu access/refresh token trong Keychain (iOS) / EncryptedSharedPreferences
/// (Android). KHÔNG bao giờ lưu token ở SharedPreferences thường.
class SecureTokenStorage {
  const SecureTokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
