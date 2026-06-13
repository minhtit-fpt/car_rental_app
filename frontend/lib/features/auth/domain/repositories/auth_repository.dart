import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthSession> register({
    required String phone,
    required String password,
    String? email,
  });

  Future<AuthSession> login({
    required String phone,
    required String password,
  });

  Future<AuthUser> getCurrentUser();

  Future<void> logout();
}
