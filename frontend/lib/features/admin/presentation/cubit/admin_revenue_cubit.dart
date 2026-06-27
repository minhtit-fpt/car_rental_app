import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/get_admin_revenue_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_revenue_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_revenue_state.dart';

class AdminRevenueCubit extends Cubit<AdminRevenueState> {
  AdminRevenueCubit({required GetAdminRevenueUseCase getRevenue})
    : _getRevenue = getRevenue,
      super(const AdminRevenueLoading());

  final GetAdminRevenueUseCase _getRevenue;

  Future<void> load() async {
    emit(const AdminRevenueLoading());
    try {
      emit(AdminRevenueLoaded(await _getRevenue()));
    } on ApiException catch (e) {
      emit(AdminRevenueError(e.message));
    }
  }
}
