import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/get_admin_stats_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_state.dart';

/// Quản lý số liệu tổng quan của màn admin.
class AdminCubit extends Cubit<AdminStatsState> {
  AdminCubit({required GetAdminStatsUseCase getStats})
      : _getStats = getStats,
        super(const AdminStatsLoading());

  final GetAdminStatsUseCase _getStats;

  Future<void> loadStats() async {
    emit(const AdminStatsLoading());
    try {
      emit(AdminStatsLoaded(await _getStats()));
    } on ApiException catch (e) {
      emit(AdminStatsError(e.message));
    }
  }
}
