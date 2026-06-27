/// Một người dùng trong danh sách quản trị (`/api/admin/users`).
class AdminUserItem {
  const AdminUserItem({
    required this.id,
    required this.phone,
    required this.roles,
    required this.kycStatus,
    required this.createdAt,
    this.email,
  });

  final String id;
  final String phone;
  final String? email;
  final List<String> roles; // RENTER | OWNER | ADMIN
  final String kycStatus;
  final DateTime createdAt;

  bool get isVerified => kycStatus == 'VERIFIED';
  bool get hasRenter => roles.contains('RENTER');
  bool get hasOwner => roles.contains('OWNER');
}
