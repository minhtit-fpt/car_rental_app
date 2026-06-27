import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/storage/secure_storage.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontend/features/auth/data/models/auth_tokens_model.dart';
import 'package:frontend/features/auth/data/models/auth_user_model.dart';
import 'package:frontend/features/auth/domain/entities/auth_user.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._secureStorage);

  final AuthRemoteDataSource _remote;
  final SecureStorage _secureStorage;

  @override
  Future<AuthUser> login({
    required String phone,
    required String password,
  }) async {
    final result = await _remote.login(phone: phone, password: password);
    return _persistSession(result);
  }

  @override
  Future<AuthUser> register({
    required String phone,
    required String password,
    String? email,
  }) async {
    final result = await _remote.register(
      phone: phone,
      password: password,
      email: email,
    );
    return _persistSession(result);
  }

  @override
  Future<AuthUser?> currentUser() async {
    final token = await _secureStorage.readAccessToken();
    if (token == null || token.isEmpty) return null;
    try {
      return AuthUserModel.fromJson(await _remote.me());
    } on ApiException {
      // Token chết & refresh thất bại → coi như chưa đăng nhập.
      await _secureStorage.clear();
      return null;
    }
  }

  @override
  Future<AuthUser> updateProfile({String? email}) async =>
      AuthUserModel.fromJson(await _remote.updateProfile(email: email));

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _remote.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );

  @override
  Future<void> deleteAccount() async {
    await _remote.deleteAccount();
    // Tài khoản đã mất ở server → xoá token cục bộ để phiên kết thúc ngay.
    await _secureStorage.clear();
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _secureStorage.readRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _remote.logout(refreshToken);
      }
    } on ApiException {
      // Server lỗi vẫn xoá token cục bộ — đăng xuất phải luôn thành công ở client.
    } finally {
      await _secureStorage.clear();
    }
  }

  Future<AuthUser> _persistSession(Map<String, dynamic> result) async {
    final tokens = AuthTokensModel.fromJson(
      result['tokens'] as Map<String, dynamic>,
    );
    final user = AuthUserModel.fromJson(result['user'] as Map<String, dynamic>);
    await _secureStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    await _secureStorage.saveRoles(
      user.roles.map((r) => r.apiValue).toList(growable: false),
    );
    return user;
  }
}
