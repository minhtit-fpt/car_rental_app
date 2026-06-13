sealed class AuthState {}

final class AuthIdle extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthOtpSent extends AuthState {
  AuthOtpSent(this.phone);
  final String phone;
}

final class AuthSuccess extends AuthState {}

final class AuthError extends AuthState {
  AuthError(this.message);
  final String message;
}
