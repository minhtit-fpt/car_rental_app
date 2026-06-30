import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/get_admin_metrics_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_metrics_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_metrics_state.dart';

class AdminMetricsCubit extends Cubit<AdminMetricsState> {
  AdminMetricsCubit({required GetAdminMetricsUseCase getMetrics})
    : _getMetrics = getMetrics,
      super(const AdminMetricsLoading());

  final GetAdminMetricsUseCase _getMetrics;

  Future<void> load() async {
    emit(const AdminMetricsLoading());
    try {
      emit(AdminMetricsLoaded(await _getMetrics()));
    } on ApiException catch (e) {
      emit(AdminMetricsError(e.message));
    }
  }
}
