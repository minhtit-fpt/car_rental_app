import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/storage/secure_token_storage.dart';
import 'package:frontend/features/auth/domain/auth_exception.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required GetCurrentUserUseCase getCurrentUser,
    required UpdateProfileUseCase updateProfile,
    required SecureTokenStorage storage,
  })  : _login = login,
        _register = register,
        _logout = logout,
        _getCurrentUser = getCurrentUser,
        _updateProfile = updateProfile,
        _storage = storage,
        super(const AuthInitial());

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _getCurrentUser;
  final UpdateProfileUseCase _updateProfile;
  final SecureTokenStorage _storage;

  /// Khôi phục phiên lúc khởi động: có token → gọi /me xác thực.
  Future<void> bootstrap() async {
    final token = await _storage.readAccessToken();
    if (token == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    try {
      emit(AuthAuthenticated(await _getCurrentUser()));
    } on AuthException {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final session = await _login(phone: phone, password: password);
      emit(AuthAuthenticated(session.user));
    } on AuthException catch (e) {
      emit(AuthUnauthenticated(message: e.message));
    }
  }

  Future<void> register({
    required String phone,
    required String password,
    String? email,
  }) async {
    emit(const AuthLoading());
    try {
      final session = await _register(
        phone: phone,
        password: password,
        email: email,
      );
      emit(AuthAuthenticated(session.user));
    } on AuthException catch (e) {
      emit(AuthUnauthenticated(message: e.message));
    }
  }

  /// Cập nhật hồ sơ (MVP: email). Trả về thông báo lỗi, hoặc null nếu thành công.
  Future<String?> updateEmail(String? email) async {
    final current = state;
    if (current is! AuthAuthenticated) return null;
    try {
      final updated = await _updateProfile(email: email);
      emit(AuthAuthenticated(updated));
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    await _logout();
    emit(const AuthUnauthenticated());
  }

  /// Gọi từ AuthInterceptor khi refresh thất bại.
  void markSessionExpired() {
    emit(
      const AuthUnauthenticated(
        message: 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại',
      ),
    );
  }
}
