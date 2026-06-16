import 'package:frontend/features/auth/domain/entities/auth_user.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String phone,
    required String password,
  }) =>
      _repository.login(phone: phone, password: password);
}
