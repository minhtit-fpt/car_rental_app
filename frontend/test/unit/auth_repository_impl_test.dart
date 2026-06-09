import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/core/storage/secure_token_storage.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/auth_exception.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/entities/auth_tokens.dart';
import 'package:frontend/features/auth/domain/entities/auth_user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

void main() {
  late MockAuthRemoteDataSource remote;
  late MockSecureTokenStorage storage;
  late AuthRepositoryImpl repository;

  const session = AuthSession(
    user: AuthUser(
      id: 'user-1',
      phone: '+84901234567',
      roles: ['RENTER'],
      kycStatus: 'UNVERIFIED',
    ),
    tokens: AuthTokens(accessToken: 'a.jwt', refreshToken: 'raw-refresh'),
  );

  setUp(() {
    remote = MockAuthRemoteDataSource();
    storage = MockSecureTokenStorage();
    repository = AuthRepositoryImpl(remote, storage);
  });

  test('login persists the issued tokens', () async {
    when(() => remote.login(
          phone: any(named: 'phone'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => session);
    when(() => storage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});

    final result = await repository.login(phone: 'p', password: 'pw');

    expect(result, session);
    verify(() => storage.saveTokens(
          accessToken: 'a.jwt',
          refreshToken: 'raw-refresh',
        )).called(1);
  });

  test('logout clears storage even when the API call fails', () async {
    when(() => storage.readRefreshToken()).thenAnswer((_) async => 'raw');
    when(() => remote.logout(any()))
        .thenThrow(const AuthException('Server lỗi'));
    when(() => storage.clear()).thenAnswer((_) async {});

    await repository.logout();

    verify(() => storage.clear()).called(1);
  });

  test('logout skips the API call when no refresh token is stored', () async {
    when(() => storage.readRefreshToken()).thenAnswer((_) async => null);
    when(() => storage.clear()).thenAnswer((_) async {});

    await repository.logout();

    verifyNever(() => remote.logout(any()));
    verify(() => storage.clear()).called(1);
  });
}
