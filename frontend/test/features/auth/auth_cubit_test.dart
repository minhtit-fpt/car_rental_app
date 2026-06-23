import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/auth/domain/entities/auth_user.dart';
import 'package:frontend/features/auth/domain/entities/user_role.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';

const _user = AuthUser(
  id: 'u1',
  phone: '+84912345678',
  roles: [UserRole.renter],
  kycStatus: 'UNVERIFIED',
);

/// Fake cấu hình được — không chạm mạng/lưu trữ.
class _FakeAuthRepository implements AuthRepository {
  AuthUser? loginResult;
  Object? loginError;
  AuthUser? currentUserResult;
  bool loggedOut = false;
  bool deleted = false;
  Object? deleteError;

  @override
  Future<AuthUser> login({
    required String phone,
    required String password,
  }) async {
    if (loginError != null) throw loginError!;
    return loginResult!;
  }

  @override
  Future<AuthUser> register({
    required String phone,
    required String password,
    String? email,
  }) async {
    if (loginError != null) throw loginError!;
    return loginResult!;
  }

  @override
  Future<AuthUser?> currentUser() async => currentUserResult;

  @override
  Future<void> logout() async => loggedOut = true;

  @override
  Future<AuthUser> updateProfile({String? email}) async =>
      currentUserResult ?? loginResult!;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<void> deleteAccount() async {
    if (deleteError != null) throw deleteError!;
    deleted = true;
  }
}

AuthCubit _buildCubit(_FakeAuthRepository repo) => AuthCubit(
      login: LoginUseCase(repo),
      register: RegisterUseCase(repo),
      logout: LogoutUseCase(repo),
      getCurrentUser: GetCurrentUserUseCase(repo),
      updateProfile: UpdateProfileUseCase(repo),
      deleteAccount: DeleteAccountUseCase(repo),
    );

void main() {
  group('AuthCubit', () {
    late _FakeAuthRepository repo;

    setUp(() => repo = _FakeAuthRepository());

    test('starts in unknown status', () {
      expect(_buildCubit(repo).state.status, AuthStatus.unknown);
    });

    blocTest<AuthCubit, AuthState>(
      'checkSession → authenticated when a session exists',
      build: () {
        repo.currentUserResult = _user;
        return _buildCubit(repo);
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', _user),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'checkSession → unauthenticated when no session',
      build: () {
        repo.currentUserResult = null;
        return _buildCubit(repo);
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login success emits authenticating then authenticated',
      build: () {
        repo.loginResult = _user;
        return _buildCubit(repo);
      },
      act: (cubit) => cubit.login(phone: '0912345678', password: 'secret123'),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticating),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', _user),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login failure surfaces the API error message',
      build: () {
        repo.loginError = const ApiException(
          'Số điện thoại hoặc mật khẩu không đúng',
          code: 'INVALID_CREDENTIALS',
        );
        return _buildCubit(repo);
      },
      act: (cubit) => cubit.login(phone: '0912345678', password: 'wrong'),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticating),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Số điện thoại hoặc mật khẩu không đúng',
            ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'logout clears session to unauthenticated',
      build: () => _buildCubit(repo),
      seed: () => const AuthState(status: AuthStatus.authenticated, user: _user),
      act: (cubit) => cubit.logout(),
      verify: (_) => expect(repo.loggedOut, isTrue),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'deleteAccount success ends the session (unauthenticated)',
      build: () => _buildCubit(repo),
      seed: () => const AuthState(status: AuthStatus.authenticated, user: _user),
      act: (cubit) => cubit.deleteAccount(),
      verify: (_) => expect(repo.deleted, isTrue),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'deleteAccount failure keeps the session and surfaces the error',
      build: () {
        repo.deleteError = const ApiException(
          'Lỗi máy chủ',
          code: 'INTERNAL_ERROR',
        );
        return _buildCubit(repo);
      },
      seed: () => const AuthState(status: AuthStatus.authenticated, user: _user),
      act: (cubit) => cubit.deleteAccount(),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.errorMessage, 'errorMessage', 'Lỗi máy chủ'),
      ],
    );
  });
}
