/// Vai trò người dùng — khớp enum `UserRole` (RENTER|OWNER|ADMIN) ở backend.
/// Một tài khoản có thể đồng thời là RENTER và OWNER.
enum UserRole {
  renter,
  owner,
  admin;

  /// Parse từ giá trị server. Giá trị lạ → mặc định [renter] (an toàn nhất).
  static UserRole fromApi(String value) => switch (value.toUpperCase()) {
        'OWNER' => UserRole.owner,
        'ADMIN' => UserRole.admin,
        _ => UserRole.renter,
      };

  String get apiValue => switch (this) {
        UserRole.renter => 'RENTER',
        UserRole.owner => 'OWNER',
        UserRole.admin => 'ADMIN',
      };
}
