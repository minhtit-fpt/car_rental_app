import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';

abstract interface class KycRepository {
  Future<KycStatusInfo> getStatus();
}
