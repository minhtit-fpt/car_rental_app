import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/list_risk_flags_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_risk_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_risk_state.dart';

/// Hàng đợi tài khoản bị cờ rủi ro (rule-engine, chỉ đọc).
class AdminRiskCubit extends Cubit<AdminRiskState> {
  AdminRiskCubit({required ListRiskFlagsUseCase listRiskFlags})
    : _listRiskFlags = listRiskFlags,
      super(const AdminRiskLoading());

  final ListRiskFlagsUseCase _listRiskFlags;

  Future<void> load() async {
    emit(const AdminRiskLoading());
    try {
      emit(AdminRiskLoaded(await _listRiskFlags()));
    } on ApiException catch (e) {
      emit(AdminRiskError(e.message));
    }
  }
}
