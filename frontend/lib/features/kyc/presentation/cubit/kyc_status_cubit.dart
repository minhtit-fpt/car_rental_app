import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/kyc/domain/usecases/get_kyc_status_usecase.dart';
import 'package:frontend/features/kyc/presentation/cubit/kyc_status_state.dart';

export 'package:frontend/features/kyc/presentation/cubit/kyc_status_state.dart';

class KycStatusCubit extends Cubit<KycStatusState> {
  KycStatusCubit({required GetKycStatusUseCase getStatus})
    : _getStatus = getStatus,
      super(const KycStatusLoading());

  final GetKycStatusUseCase _getStatus;

  Future<void> load() async {
    emit(const KycStatusLoading());
    try {
      emit(KycStatusLoaded(await _getStatus()));
    } on ApiException catch (e) {
      emit(KycStatusFailure(e.message));
    }
  }
}
