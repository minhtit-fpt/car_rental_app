import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';
import 'package:frontend/features/kyc/domain/repositories/kyc_repository.dart';

class GetKycStatusUseCase {
  const GetKycStatusUseCase(this._repository);

  final KycRepository _repository;

  Future<KycStatusInfo> call() => _repository.getStatus();
}
