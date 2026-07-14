import 'package:frontend/features/tracking/domain/entities/tracking_snapshot.dart';

sealed class TrackingState {
  const TrackingState();
}

final class TrackingLoading extends TrackingState {
  const TrackingLoading();
}

/// Có dữ liệu vị trí. [snapshot] cập nhật mỗi lần poll; UI animate marker giữa
/// [previous]?.latest và [snapshot].latest cho mượt.
final class TrackingLoaded extends TrackingState {
  const TrackingLoaded({required this.snapshot, this.previous});

  final TrackingSnapshot snapshot;
  final TrackingSnapshot? previous;

  TrackingLoaded next(TrackingSnapshot updated) =>
      TrackingLoaded(snapshot: updated, previous: snapshot);
}

final class TrackingError extends TrackingState {
  const TrackingError(this.message);
  final String message;
}
