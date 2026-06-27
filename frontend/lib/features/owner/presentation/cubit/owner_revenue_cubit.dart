import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/owner/domain/usecases/get_owner_revenue_usecase.dart';
import 'package:frontend/features/owner/presentation/cubit/owner_revenue_state.dart';

export 'package:frontend/features/owner/presentation/cubit/owner_revenue_state.dart';

/// Tổng quan doanh thu chủ xe (`GET /api/owner/revenue`).
class OwnerRevenueCubit extends Cubit<OwnerRevenueState> {
  OwnerRevenueCubit({required GetOwnerRevenueUseCase getRevenue})
    : _getRevenue = getRevenue,
      super(const OwnerRevenueLoading());

  final GetOwnerRevenueUseCase _getRevenue;

  Future<void> load({int months = 6}) async {
    emit(const OwnerRevenueLoading());
    try {
      emit(OwnerRevenueLoaded(await _getRevenue(months: months)));
    } on ApiException catch (e) {
      emit(OwnerRevenueError(e.message));
    }
  }
}
