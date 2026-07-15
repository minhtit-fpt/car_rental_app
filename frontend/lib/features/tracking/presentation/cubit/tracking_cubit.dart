import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/tracking/domain/usecases/get_tracking_snapshot_usecase.dart';
import 'package:frontend/features/tracking/presentation/cubit/tracking_state.dart';

/// Theo dõi vị trí realtime một xe bằng cách poll `/latest` mỗi [pollInterval].
/// Timer bị huỷ khi [close] để tránh rò rỉ.
class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit({required GetTrackingSnapshotUseCase getSnapshot})
    : _getSnapshot = getSnapshot,
      super(const TrackingLoading());

  final GetTrackingSnapshotUseCase _getSnapshot;

  static const pollInterval = Duration(seconds: 3);
  static const _trail = 20;

  Timer? _timer;
  String? _vehicleId;

  void start(String vehicleId) {
    _vehicleId = vehicleId;
    emit(const TrackingLoading());
    _tick();
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) => _tick());
  }

  /// Thử lại sau lỗi — poll lại xe hiện tại.
  void retry() {
    final id = _vehicleId;
    if (id != null) start(id);
  }

  Future<void> _tick() async {
    final id = _vehicleId;
    if (id == null) return;
    try {
      final snapshot = await _getSnapshot(id, trail: _trail);
      if (isClosed) return;
      final current = state;
      emit(
        current is TrackingLoaded
            ? current.next(snapshot)
            : TrackingLoaded(snapshot: snapshot),
      );
    } on ApiException catch (e) {
      // Lỗi lúc đang chạy (đã có dữ liệu) → giữ bản đồ hiện tại, chờ tick sau.
      // Lỗi ngay lần đầu → báo lỗi.
      if (isClosed) return;
      if (state is! TrackingLoaded) emit(TrackingError(e.message));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
