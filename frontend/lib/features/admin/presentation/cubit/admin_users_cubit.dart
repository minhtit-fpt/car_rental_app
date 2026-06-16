import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_users_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_users_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  AdminUsersCubit({required ListAdminUsersUseCase listUsers})
    : _listUsers = listUsers,
      super(const AdminUsersLoading());

  final ListAdminUsersUseCase _listUsers;

  Future<void> load() async {
    emit(const AdminUsersLoading());
    try {
      emit(AdminUsersLoaded(await _listUsers()));
    } on ApiException catch (e) {
      emit(AdminUsersError(e.message));
    }
  }
}
