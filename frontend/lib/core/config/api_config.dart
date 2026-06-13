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

class UserEndpoints {
  UserEndpoints._();

  // PATCH hồ sơ của chính mình.
  static const String me = '/users/me';

  // Danh sách đánh giá nhận được của một user.
  static String reviews(String id) => '/users/$id/reviews';
}

class ReviewEndpoints {
  ReviewEndpoints._();

  static const String create = '/reviews';
}

class KycEndpoints {
  KycEndpoints._();

  static const String uploadUrl = '/kyc/upload-url';
  static const String submit = '/kyc/submit';
  static const String status = '/kyc/status';
}

class VehicleEndpoints {
  VehicleEndpoints._();

  static const String list = '/vehicles';
  static const String nearby = '/vehicles/nearby';

  static String detail(String id) => '/vehicles/$id';
}

class BookingEndpoints {
  BookingEndpoints._();

  // POST tạo đơn + GET danh sách đơn của tôi dùng chung path này.
  static const String list = '/bookings';

  static String detail(String id) => '/bookings/$id';
  static String cancel(String id) => '/bookings/$id/cancel';
}

class PaymentEndpoints {
  PaymentEndpoints._();

  // POST tạo phiên thanh toán.
  static const String list = '/payments';

  static String detail(String id) => '/payments/$id';
  static String confirm(String id) => '/payments/$id/confirm';
}
