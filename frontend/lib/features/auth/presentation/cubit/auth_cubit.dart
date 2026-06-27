import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_state.dart';

export 'package:frontend/features/auth/presentation/cubit/auth_state.dart';

/// Cubit phiên đăng nhập — singleton, cung cấp ở gốc app. Router lắng nghe
/// stream này để chuyển hướng (guard) khi trạng thái đổi.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required GetCurrentUserUseCase getCurrentUser,
    required UpdateProfileUseCase updateProfile,
    required DeleteAccountUseCase deleteAccount,
  }) : _login = login,
       _register = register,
       _logout = logout,
       _getCurrentUser = getCurrentUser,
       _updateProfile = updateProfile,
       _deleteAccount = deleteAccount,
       super(const AuthState.unknown());

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _getCurrentUser;
  final UpdateProfileUseCase _updateProfile;
  final DeleteAccountUseCase _deleteAccount;

  /// Gọi 1 lần lúc khởi động: token còn hạn → authenticated, ngược lại → unauthenticated.
  Future<void> checkSession() async {
    final user = await _getCurrentUser();
    emit(
      user == null
          ? const AuthState(status: AuthStatus.unauthenticated)
          : AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> login({required String phone, required String password}) async {
    emit(const AuthState(status: AuthStatus.authenticating));
    try {
      final user = await _login(phone: phone, password: password);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on ApiException catch (e) {
      emit(
        AuthState(status: AuthStatus.unauthenticated, errorMessage: e.message),
      );
    }
  }

  Future<void> register({
    required String phone,
    required String password,
    String? email,
  }) async {
    emit(const AuthState(status: AuthStatus.authenticating));
    try {
      final user = await _register(
        phone: phone,
        password: password,
        email: email,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on ApiException catch (e) {
      emit(
        AuthState(status: AuthStatus.unauthenticated, errorMessage: e.message),
      );
    }
  }

  /// Cập nhật hồ sơ (email). Trả true nếu thành công; giữ phiên khi lỗi.
  Future<bool> updateProfile({String? email}) async {
    try {
      final user = await _updateProfile(email: email);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
      return true;
    } on ApiException catch (e) {
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: state.user,
          errorMessage: e.message,
        ),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Xoá cứng tài khoản rồi kết thúc phiên (router tự redirect về /login).
  /// Trả `false` và giữ phiên nếu server lỗi.
  Future<bool> deleteAccount() async {
    try {
      await _deleteAccount();
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return true;
    } on ApiException catch (e) {
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: state.user,
          errorMessage: e.message,
        ),
      );
      return false;
    }
  }
}
