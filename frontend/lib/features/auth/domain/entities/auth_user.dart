import 'package:frontend/features/auth/domain/entities/user_role.dart';

/// Người dùng đã xác thực (tương ứng `PublicUser` ở backend).
class AuthUser {
  const AuthUser({
    required this.id,
    required this.phone,
    required this.roles,
    required this.kycStatus,
    this.email,
  });

  final String id;
  final String phone;
  final String? email;
  final List<UserRole> roles;

  /// Giữ dạng chuỗi (UNVERIFIED|PENDING|VERIFIED|REJECTED…) — UI chỉ hiển thị.
  final String kycStatus;

  bool get isRenter => roles.contains(UserRole.renter);
  bool get isOwner => roles.contains(UserRole.owner);
  bool get isAdmin => roles.contains(UserRole.admin);
}
