/// Cặp token nhận từ backend sau login/register/refresh.
class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}
