import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/tracking/domain/entities/tracking_snapshot.dart';
import 'package:frontend/features/tracking/domain/usecases/get_tracking_snapshot_usecase.dart';

sealed class AdminTrackingState {
  const AdminTrackingState();
}

final class AdminTrackingLoading extends AdminTrackingState {
  const AdminTrackingLoading();
}

final class AdminTrackingLoaded extends AdminTrackingState {
  const AdminTrackingLoaded(this.vehicles);
  final List<ActiveVehicleLocation> vehicles;
}

final class AdminTrackingError extends AdminTrackingState {
  const AdminTrackingError(this.message);
  final String message;
}

/// Map admin: mọi xe đang chạy. Poll `/active` mỗi [pollInterval]; huỷ khi close.
class AdminTrackingCubit extends Cubit<AdminTrackingState> {
  AdminTrackingCubit({required GetActiveTrackingUseCase getActive})
    : _getActive = getActive,
      super(const AdminTrackingLoading());

  final GetActiveTrackingUseCase _getActive;

  static const pollInterval = Duration(seconds: 8);
  Timer? _timer;

  void start() {
    emit(const AdminTrackingLoading());
    _tick();
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) => _tick());
  }

  Future<void> _tick() async {
    try {
      final vehicles = await _getActive();
      if (isClosed) return;
      emit(AdminTrackingLoaded(vehicles));
    } on ApiException catch (e) {
      if (isClosed) return;
      if (state is! AdminTrackingLoaded) emit(AdminTrackingError(e.message));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
