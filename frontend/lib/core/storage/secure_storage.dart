import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Kho bảo mật phần cứng (Keychain iOS / Keystore Android).
/// CHỈ chứa token + role. KHÔNG để trong SQLite (file .db đọc được nếu máy bị root).
class SecureStorage {
  const SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserRoles = 'user_roles';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);

  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);

  /// roles dạng CSV: "RENTER,OWNER" (khớp roles[] phía server).
  Future<void> saveRoles(List<String> roles) =>
      _storage.write(key: _kUserRoles, value: roles.join(','));

  Future<List<String>> readRoles() async {
    final raw = await _storage.read(key: _kUserRoles);
    if (raw == null || raw.isEmpty) return const [];
    return raw.split(',');
  }

  /// Xoá toàn bộ khi đăng xuất.
  Future<void> clear() => _storage.deleteAll();
}
