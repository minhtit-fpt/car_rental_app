import 'package:equatable/equatable.dart';

/// Trạng thái KYC, khớp enum backend (UNVERIFIED|PENDING|VERIFIED|REJECTED).
enum KycStatus { unverified, pending, verified, rejected }

KycStatus kycStatusFromWire(String? value) => switch (value) {
      'PENDING' => KycStatus.pending,
      'VERIFIED' => KycStatus.verified,
      'REJECTED' => KycStatus.rejected,
      _ => KycStatus.unverified,
    };

/// Thông tin trạng thái KYC hiện tại của người dùng.
class KycStatusInfo extends Equatable {
  const KycStatusInfo({
    required this.status,
    this.rejectReason,
    this.reviewedAt,
    this.submittedAt,
  });

  final KycStatus status;
  final String? rejectReason;
  final DateTime? reviewedAt;
  final DateTime? submittedAt;

  /// Chỉ cho phép nộp hồ sơ khi chưa xác minh hoặc bị từ chối.
  bool get canSubmit =>
      status == KycStatus.unverified || status == KycStatus.rejected;

  @override
  List<Object?> get props => [status, rejectReason, reviewedAt, submittedAt];
}
