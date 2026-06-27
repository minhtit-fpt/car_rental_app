import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';

sealed class KycStatusState {
  const KycStatusState();
}

final class KycStatusLoading extends KycStatusState {
  const KycStatusLoading();
}

final class KycStatusLoaded extends KycStatusState {
  const KycStatusLoaded(this.info);
  final KycStatusInfo info;
}

final class KycStatusFailure extends KycStatusState {
  const KycStatusFailure(this.message);
  final String message;
}
