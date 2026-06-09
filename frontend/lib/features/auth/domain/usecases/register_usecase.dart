import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String phone,
    required String password,
    String? email,
  }) {
    return _repository.register(
      phone: phone,
      password: password,
      email: email,
    );
  }
}
