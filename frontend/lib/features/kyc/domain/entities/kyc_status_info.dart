/// Trạng thái KYC của người dùng (`/api/kyc/status`).
class KycStatusInfo {
  const KycStatusInfo({
    required this.status,
    this.rejectReason,
    this.reviewedAt,
    this.submittedAt,
  });

  /// UNVERIFIED | PENDING | VERIFIED | REJECTED.
  final String status;
  final String? rejectReason;
  final DateTime? reviewedAt;
  final DateTime? submittedAt;
}
