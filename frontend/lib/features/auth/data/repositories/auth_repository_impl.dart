import 'package:frontend/core/storage/secure_token_storage.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontend/features/auth/domain/auth_exception.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/entities/auth_user.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final SecureTokenStorage _storage;

  @override
  Future<AuthSession> register({
    required String phone,
    required String password,
    String? email,
  }) async {
    final session = await _remote.register(
      phone: phone,
      password: password,
      email: email,
    );
    await _persist(session);
    return session;
  }

  @override
  Future<AuthSession> login({
    required String phone,
    required String password,
  }) async {
    final session = await _remote.login(phone: phone, password: password);
    await _persist(session);
    return session;
  }

  @override
  Future<AuthUser> getCurrentUser() => _remote.getCurrentUser();

  @override
  Future<AuthUser> updateProfile({String? email}) =>
      _remote.updateProfile(email: email);

  @override
  Future<void> logout() async {
    final refreshToken = await _storage.readRefreshToken();
    try {
      if (refreshToken != null) {
        await _remote.logout(refreshToken);
      }
    } on AuthException {
      // Best-effort: vẫn xóa token local kể cả khi API logout lỗi.
    }
    await _storage.clear();
  }

  Future<void> _persist(AuthSession session) {
    return _storage.saveTokens(
      accessToken: session.tokens.accessToken,
      refreshToken: session.tokens.refreshToken,
    );
  }
}
