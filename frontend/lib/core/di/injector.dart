import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/core/db/app_database.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/kv_storage.dart';
import 'package:frontend/core/storage/secure_storage.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:frontend/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:frontend/features/admin/domain/usecases/get_admin_stats_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_cubit.dart';

/// Service locator toàn cục.
final GetIt sl = GetIt.instance;

/// Đăng ký 3 kho lưu trữ trên máy. Gọi 1 lần trong main() trước runApp().
Future<void> setupStorage() async {
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<AppDatabase>(AppDatabase())
    ..registerSingleton<SecureStorage>(
      const SecureStorage(FlutterSecureStorage()),
    )
    ..registerSingleton<KvStorage>(KvStorage(prefs));
}

/// Đăng ký network + auth (data → domain → presentation). Gọi sau [setupStorage].
/// [AuthCubit] là singleton để router và các màn auth dùng chung 1 phiên.
void setupAuth() {
  sl.registerSingleton<ApiClient>(ApiClient(sl<SecureStorage>()));

  final repository = AuthRepositoryImpl(
    AuthRemoteDataSource(sl<ApiClient>()),
    sl<SecureStorage>(),
  );

  sl
    ..registerSingleton<AuthRepository>(repository)
    ..registerSingleton<AuthCubit>(
      AuthCubit(
        login: LoginUseCase(sl<AuthRepository>()),
        register: RegisterUseCase(sl<AuthRepository>()),
        logout: LogoutUseCase(sl<AuthRepository>()),
        getCurrentUser: GetCurrentUserUseCase(sl<AuthRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho admin. Gọi sau [setupAuth] (cần [ApiClient]).
/// [AdminCubit] là factory — mỗi lần mở màn admin tạo mới + load lại số liệu.
void setupAdmin() {
  sl
    ..registerSingleton<AdminRepository>(
      AdminRepositoryImpl(AdminRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<AdminCubit>(
      () => AdminCubit(getStats: GetAdminStatsUseCase(sl<AdminRepository>())),
    );
}
