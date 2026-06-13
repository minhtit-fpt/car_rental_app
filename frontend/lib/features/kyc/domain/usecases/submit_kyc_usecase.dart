import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';
import 'package:frontend/features/kyc/domain/repositories/kyc_repository.dart';

class SubmitKycUseCase {
  const SubmitKycUseCase(this._repository);

  final KycRepository _repository;

  Future<KycStatusInfo> call({
    required String cccdKey,
    required String licenseKey,
    required String faceKey,
  }) =>
      _repository.submit(
        cccdKey: cccdKey,
        licenseKey: licenseKey,
        faceKey: faceKey,
      );
}
