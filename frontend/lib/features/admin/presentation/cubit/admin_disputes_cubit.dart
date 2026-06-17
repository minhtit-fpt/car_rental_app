import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_disputes_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_disputes_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_disputes_state.dart';

class AdminDisputesCubit extends Cubit<AdminDisputesState> {
  AdminDisputesCubit({required ListAdminDisputesUseCase listDisputes})
    : _listDisputes = listDisputes,
      super(const AdminDisputesLoading());

  final ListAdminDisputesUseCase _listDisputes;

  Future<void> load() async {
    emit(const AdminDisputesLoading());
    try {
      emit(AdminDisputesLoaded(await _listDisputes()));
    } on ApiException catch (e) {
      emit(AdminDisputesError(e.message));
    }
  }
}
