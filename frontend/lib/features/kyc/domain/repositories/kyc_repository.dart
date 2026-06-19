import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';

abstract interface class KycRepository {
  Future<KycStatusInfo> getStatus();

  /// Upload một ảnh giấy tờ (presign + PUT) và trả về `objectKey` của nó.
  /// [docType] ∈ {cccd, license, face}; [contentType] ∈ {image/jpeg, image/png}.
  Future<String> uploadDocument({
    required String docType,
    required List<int> bytes,
    required String contentType,
  });

  /// Gửi hồ sơ KYC từ 3 object key đã upload (`POST /api/kyc/submit`).
  Future<void> submitKyc({
    required String cccdKey,
    required String licenseKey,
    required String faceKey,
  });
}
