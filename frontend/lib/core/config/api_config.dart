/// Cấu hình API. Base URL override bằng --dart-define=API_BASE_URL=...
class ApiConfig {
  ApiConfig._();

  // 10.0.2.2 = localhost của máy host khi chạy Android emulator.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

class AuthEndpoints {
  AuthEndpoints._();

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
}
