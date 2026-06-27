import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/auth/domain/entities/auth_user.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:frontend/features/auth/presentation/cubit/change_password_cubit.dart';

/// Fake chỉ phục vụ changePassword; các method khác không dùng trong test này.
class _FakeAuthRepository implements AuthRepository {
  Object? changeError;
  bool changed = false;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (changeError != null) throw changeError!;
    changed = true;
  }

  @override
  Future<void> deleteAccount() async => throw UnimplementedError();
  @override
  Future<AuthUser?> currentUser() async => throw UnimplementedError();
  @override
  Future<AuthUser> login({
    required String phone,
    required String password,
  }) async => throw UnimplementedError();
  @override
  Future<void> logout() async => throw UnimplementedError();
  @override
  Future<AuthUser> register({
    required String phone,
    required String password,
    String? email,
  }) async => throw UnimplementedError();
  @override
  Future<AuthUser> updateProfile({String? email}) async =>
      throw UnimplementedError();
}

ChangePasswordCubit _build(_FakeAuthRepository repo) =>
    ChangePasswordCubit(ChangePasswordUseCase(repo));

void main() {
  group('ChangePasswordCubit', () {
    late _FakeAuthRepository repo;
    setUp(() => repo = _FakeAuthRepository());

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'emits [Submitting, Success] when the change succeeds',
      build: () => _build(repo),
      act: (cubit) =>
          cubit.submit(currentPassword: 'oldpass1', newPassword: 'newpass12'),
      verify: (_) => expect(repo.changed, isTrue),
      expect: () => [isA<ChangePasswordSubmitting>(), isA<ChangePasswordSuccess>()],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'emits [Submitting, Failure] with the API message when current is wrong',
      build: () {
        repo.changeError = const ApiException(
          'Mật khẩu hiện tại không đúng',
          code: 'INVALID_CURRENT_PASSWORD',
        );
        return _build(repo);
      },
      act: (cubit) =>
          cubit.submit(currentPassword: 'wrong', newPassword: 'newpass12'),
      expect: () => [
        isA<ChangePasswordSubmitting>(),
        isA<ChangePasswordFailure>().having(
          (s) => s.message,
          'message',
          'Mật khẩu hiện tại không đúng',
        ),
      ],
    );
  });
}
