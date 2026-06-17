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
import 'package:frontend/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:frontend/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:frontend/features/admin/domain/usecases/get_admin_stats_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_kyc_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_users_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/get_admin_revenue_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_disputes_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_kyc_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_users_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_revenue_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_disputes_cubit.dart';
import 'package:frontend/features/vehicle/data/datasources/vehicle_remote_datasource.dart';
import 'package:frontend/features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:frontend/features/vehicle/domain/usecases/list_vehicles_usecase.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_cubit.dart';
import 'package:frontend/features/kyc/data/datasources/kyc_remote_datasource.dart';
import 'package:frontend/features/kyc/data/repositories/kyc_repository_impl.dart';
import 'package:frontend/features/kyc/domain/repositories/kyc_repository.dart';
import 'package:frontend/features/kyc/domain/usecases/get_kyc_status_usecase.dart';
import 'package:frontend/features/kyc/presentation/cubit/kyc_status_cubit.dart';

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
        updateProfile: UpdateProfileUseCase(sl<AuthRepository>()),
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
    )
    ..registerFactory<AdminUsersCubit>(
      () => AdminUsersCubit(
        listUsers: ListAdminUsersUseCase(sl<AdminRepository>()),
      ),
    )
    ..registerFactory<AdminKycCubit>(
      () => AdminKycCubit(listKyc: ListAdminKycUseCase(sl<AdminRepository>())),
    )
    ..registerFactory<AdminRevenueCubit>(
      () => AdminRevenueCubit(
        getRevenue: GetAdminRevenueUseCase(sl<AdminRepository>()),
      ),
    )
    ..registerFactory<AdminDisputesCubit>(
      () => AdminDisputesCubit(
        listDisputes: ListAdminDisputesUseCase(sl<AdminRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho xe. Gọi sau [setupAuth] (cần [ApiClient]).
/// [VehicleListCubit] là factory — mỗi lần vào shell người thuê tạo mới + load.
void setupVehicle() {
  sl
    ..registerSingleton<VehicleRepository>(
      VehicleRepositoryImpl(VehicleRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<VehicleListCubit>(
      () => VehicleListCubit(
        listVehicles: ListVehiclesUseCase(sl<VehicleRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho KYC. Gọi sau [setupAuth] (cần [ApiClient]).
void setupKyc() {
  sl
    ..registerSingleton<KycRepository>(
      KycRepositoryImpl(KycRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<KycStatusCubit>(
      () => KycStatusCubit(getStatus: GetKycStatusUseCase(sl<KycRepository>())),
    );
}
