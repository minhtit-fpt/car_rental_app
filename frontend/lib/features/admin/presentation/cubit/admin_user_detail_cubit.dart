import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';
import 'package:frontend/features/admin/domain/usecases/update_user_role_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_user_detail_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_user_detail_state.dart';

/// Cubit cho màn chi tiết user: bật/tắt vai OWNER. Giữ user hiện tại trong state
/// để chip vai trò cập nhật ngay sau mỗi thao tác.
class AdminUserDetailCubit extends Cubit<AdminUserDetailState> {
  AdminUserDetailCubit({
    required AdminUserItem user,
    required UpdateUserRoleUseCase updateUserRole,
  }) : _updateUserRole = updateUserRole,
       super(AdminUserDetailState(user: user));

  final UpdateUserRoleUseCase _updateUserRole;

  Future<void> toggleOwner() async {
    if (state.submitting) return;
    final action = state.user.hasOwner ? 'remove' : 'add';
    emit(state.copyWith(submitting: true, error: null));
    try {
      final updated = await _updateUserRole(
        state.user.id,
        role: 'OWNER',
        action: action,
      );
      emit(state.copyWith(user: updated, submitting: false, changed: true));
    } on ApiException catch (e) {
      emit(state.copyWith(submitting: false, error: e.message));
    }
  }
}
