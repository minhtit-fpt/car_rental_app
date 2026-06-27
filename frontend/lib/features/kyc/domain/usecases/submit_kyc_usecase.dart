import 'package:frontend/features/kyc/domain/repositories/kyc_repository.dart';

/// Gửi hồ sơ KYC từ 3 object key đã upload (CCCD, bằng lái, ảnh chân dung).
class SubmitKycUseCase {
  const SubmitKycUseCase(this._repository);

  final KycRepository _repository;

  Future<void> call({
    required String cccdKey,
    required String licenseKey,
    required String faceKey,
  }) => _repository.submitKyc(
    cccdKey: cccdKey,
    licenseKey: licenseKey,
    faceKey: faceKey,
  );
}
