import 'package:frontend/features/auth/domain/entities/auth_user.dart';

enum AuthStatus {
  /// Đang khôi phục phiên lúc khởi động (chưa biết đăng nhập hay chưa).
  unknown,

  /// Đang gọi login/register.
  authenticating,

  /// Đã đăng nhập.
  authenticated,

  /// Chưa đăng nhập (gồm cả trường hợp login/register vừa thất bại).
  unauthenticated,
}

/// State phiên đăng nhập dùng chung toàn app (router đọc để guard route).
class AuthState {
  const AuthState({required this.status, this.user, this.errorMessage});

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  final AuthStatus status;
  final AuthUser? user;

  /// Lỗi gần nhất của login/register — màn hình hiển thị rồi bỏ qua.
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isBusy => status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}
