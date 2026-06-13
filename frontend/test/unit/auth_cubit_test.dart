import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/core/storage/secure_token_storage.dart';
import 'package:frontend/features/auth/domain/auth_exception.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/entities/auth_tokens.dart';
import 'package:frontend/features/auth/domain/entities/auth_user.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock
    implements GetCurrentUserUseCase {}

class MockUpdateProfileUseCase extends Mock
    implements UpdateProfileUseCase {}

class MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

void main() {
  late MockLoginUseCase login;
  late MockRegisterUseCase register;
  late MockLogoutUseCase logout;
  late MockGetCurrentUserUseCase getCurrentUser;
  late MockUpdateProfileUseCase updateProfile;
  late MockSecureTokenStorage storage;

  const user = AuthUser(
    id: 'user-1',
    phone: '+84901234567',
    roles: ['RENTER'],
    kycStatus: 'UNVERIFIED',
  );
  const session = AuthSession(
    user: user,
    tokens: AuthTokens(accessToken: 'a.jwt', refreshToken: 'raw-refresh'),
  );

  setUp(() {
    login = MockLoginUseCase();
    register = MockRegisterUseCase();
    logout = MockLogoutUseCase();
    getCurrentUser = MockGetCurrentUserUseCase();
    updateProfile = MockUpdateProfileUseCase();
    storage = MockSecureTokenStorage();
  });

  AuthCubit build() => AuthCubit(
        login: login,
        register: register,
        logout: logout,
        getCurrentUser: getCurrentUser,
        updateProfile: updateProfile,
        storage: storage,
      );

  group('login', () {
    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Authenticated] on success',
      build: () {
        when(() => login(
              phone: any(named: 'phone'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => session);
        return build();
      },
      act: (cubit) =>
          cubit.login(phone: '0901234567', password: 'password1'),
      expect: () => const [AuthLoading(), AuthAuthenticated(user)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Unauthenticated(message)] on failure',
      build: () {
        when(() => login(
              phone: any(named: 'phone'),
              password: any(named: 'password'),
            )).thenThrow(
          const AuthException('Sai thông tin', code: 'INVALID_CREDENTIALS'),
        );
        return build();
      },
      act: (cubit) => cubit.login(phone: '0901234567', password: 'wrong'),
      expect: () =>
          const [AuthLoading(), AuthUnauthenticated(message: 'Sai thông tin')],
    );
  });

  group('bootstrap', () {
    blocTest<AuthCubit, AuthState>(
      'emits [Unauthenticated] when no token stored',
      build: () {
        when(() => storage.readAccessToken()).thenAnswer((_) async => null);
        return build();
      },
      act: (cubit) => cubit.bootstrap(),
      expect: () => const [AuthUnauthenticated()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Authenticated] when token valid and /me succeeds',
      build: () {
        when(() => storage.readAccessToken()).thenAnswer((_) async => 'tok');
        when(() => getCurrentUser()).thenAnswer((_) async => user);
        return build();
      },
      act: (cubit) => cubit.bootstrap(),
      expect: () => const [AuthAuthenticated(user)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Unauthenticated] when /me fails',
      build: () {
        when(() => storage.readAccessToken()).thenAnswer((_) async => 'tok');
        when(() => getCurrentUser())
            .thenThrow(const AuthException('Hết hạn'));
        return build();
      },
      act: (cubit) => cubit.bootstrap(),
      expect: () => const [AuthUnauthenticated()],
    );
  });

  group('logout', () {
    blocTest<AuthCubit, AuthState>(
      'calls logout usecase and emits [Unauthenticated]',
      build: () {
        when(() => logout()).thenAnswer((_) async {});
        return build();
      },
      act: (cubit) => cubit.logout(),
      verify: (_) => verify(() => logout()).called(1),
      expect: () => const [AuthUnauthenticated()],
    );
  });

  group('markSessionExpired', () {
    blocTest<AuthCubit, AuthState>(
      'emits [Unauthenticated] with a message',
      build: build,
      act: (cubit) => cubit.markSessionExpired(),
      expect: () => [
        isA<AuthUnauthenticated>()
            .having((s) => s.message, 'message', isNotNull),
      ],
    );
  });

  group('updateEmail', () {
    const updated = AuthUser(
      id: 'user-1',
      phone: '+84901234567',
      email: 'new@example.com',
      roles: ['RENTER'],
      kycStatus: 'UNVERIFIED',
    );

    blocTest<AuthCubit, AuthState>(
      'emits Authenticated with the updated user on success',
      setUp: () => when(() => updateProfile(email: 'new@example.com'))
          .thenAnswer((_) async => updated),
      seed: () => const AuthAuthenticated(user),
      build: build,
      act: (cubit) => cubit.updateEmail('new@example.com'),
      expect: () => const [AuthAuthenticated(updated)],
    );

    blocTest<AuthCubit, AuthState>(
      'does not change state and returns the message on failure',
      setUp: () => when(() => updateProfile(email: any(named: 'email')))
          .thenThrow(const AuthException('Email đã dùng')),
      seed: () => const AuthAuthenticated(user),
      build: build,
      act: (cubit) async {
        final error = await cubit.updateEmail('taken@example.com');
        expect(error, 'Email đã dùng');
      },
      expect: () => const <AuthState>[],
    );
  });
}
