import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_kyc_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_kyc_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_kyc_state.dart';

class AdminKycCubit extends Cubit<AdminKycState> {
  AdminKycCubit({required ListAdminKycUseCase listKyc})
    : _listKyc = listKyc,
      super(const AdminKycLoading());

  final ListAdminKycUseCase _listKyc;

  Future<void> load() async {
    emit(const AdminKycLoading());
    try {
      emit(AdminKycLoaded(await _listKyc()));
    } on ApiException catch (e) {
      emit(AdminKycError(e.message));
    }
  }
}
