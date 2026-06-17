import 'package:frontend/features/auth/domain/entities/auth_user.dart';

/// Hợp đồng tầng domain cho xác thực. Tầng presentation gọi qua usecase,
/// không phụ thuộc vào chi tiết HTTP/lưu trữ.
abstract interface class AuthRepository {
  /// Đăng nhập bằng SĐT + mật khẩu. Lưu token khi thành công.
  Future<AuthUser> login({required String phone, required String password});

  /// Đăng ký rồi tự đăng nhập (backend trả token ngay). Lưu token khi thành công.
  Future<AuthUser> register({
    required String phone,
    required String password,
    String? email,
  });

  /// Lấy user hiện tại từ token đã lưu. Trả `null` nếu chưa đăng nhập / token hỏng.
  Future<AuthUser?> currentUser();

  /// Thu hồi refresh token ở server (best-effort) và xoá toàn bộ token cục bộ.
  Future<void> logout();

  /// Cập nhật hồ sơ (MVP: email) qua `/api/users/me`, trả user mới.
  Future<AuthUser> updateProfile({String? email});
}
