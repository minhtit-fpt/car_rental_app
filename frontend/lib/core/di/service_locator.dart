import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/storage/secure_token_storage.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/kyc/data/datasources/kyc_remote_datasource.dart';
import 'package:frontend/features/kyc/data/repositories/kyc_repository_impl.dart';
import 'package:frontend/features/kyc/domain/repositories/kyc_repository.dart';
import 'package:frontend/features/kyc/domain/usecases/get_kyc_status_usecase.dart';
import 'package:frontend/features/kyc/domain/usecases/submit_kyc_usecase.dart';
import 'package:frontend/features/kyc/domain/usecases/upload_kyc_document_usecase.dart';
import 'package:frontend/features/kyc/presentation/cubit/kyc_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // --- Storage ---
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<SecureTokenStorage>(
    () => SecureTokenStorage(getIt()),
  );

  // --- Network ---
  // onSessionExpired tra cứu AuthCubit lúc gọi (lazy) để tránh vòng phụ thuộc
  // Dio <-> AuthCubit.
  getIt.registerLazySingleton<Dio>(
    () => DioClient.create(
      storage: getIt(),
      onSessionExpired: () async => getIt<AuthCubit>().markSessionExpired(),
    ),
  );

  // --- Data ---
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );

  // --- Usecases ---
  getIt.registerFactory<LoginUseCase>(() => LoginUseCase(getIt()));
  getIt.registerFactory<RegisterUseCase>(() => RegisterUseCase(getIt()));
  getIt.registerFactory<LogoutUseCase>(() => LogoutUseCase(getIt()));
  getIt.registerFactory<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt()),
  );

  // --- Global session cubit ---
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      login: getIt(),
      register: getIt(),
      logout: getIt(),
      getCurrentUser: getIt(),
      storage: getIt(),
    ),
  );

  // --- KYC ---
  getIt.registerLazySingleton<KycRemoteDataSource>(
    () => KycRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<KycRepository>(
    () => KycRepositoryImpl(getIt()),
  );
  getIt.registerFactory<GetKycStatusUseCase>(
    () => GetKycStatusUseCase(getIt()),
  );
  getIt.registerFactory<UploadKycDocumentUseCase>(
    () => UploadKycDocumentUseCase(getIt()),
  );
  getIt.registerFactory<SubmitKycUseCase>(() => SubmitKycUseCase(getIt()));
  getIt.registerFactory<KycCubit>(
    () => KycCubit(
      getStatus: getIt(),
      upload: getIt(),
      submit: getIt(),
    ),
  );
}
