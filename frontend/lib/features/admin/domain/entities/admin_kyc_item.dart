/// Một hồ sơ KYC trong hàng chờ duyệt (`/api/admin/kyc`).
class AdminKycItem {
  const AdminKycItem({
    required this.id,
    required this.userId,
    required this.phone,
    required this.status,
    required this.submittedAt,
    this.email,
  });

  final String id;
  final String userId;
  final String phone;
  final String? email;
  final String status; // UNVERIFIED | PENDING | VERIFIED | REJECTED
  final DateTime submittedAt;
}
