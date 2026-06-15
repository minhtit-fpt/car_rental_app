import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/register_usecase.dart';
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
  })  : _login = login,
        _register = register,
        _logout = logout,
        _getCurrentUser = getCurrentUser,
        super(const AuthState.unknown());

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _getCurrentUser;

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
      emit(AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      ));
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
      emit(AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> logout() async {
    await _logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
