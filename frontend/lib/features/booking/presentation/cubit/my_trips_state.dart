import 'package:equatable/equatable.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';

sealed class MyTripsState extends Equatable {
  const MyTripsState();

  @override
  List<Object?> get props => [];
}

final class MyTripsLoading extends MyTripsState {
  const MyTripsLoading();
}

final class MyTripsLoaded extends MyTripsState {
  const MyTripsLoaded({required this.items, this.cancellingId});

  final List<Booking> items;

  /// Id đơn đang được huỷ (để khoá nút trong lúc chờ).
  final String? cancellingId;

  MyTripsLoaded copyWith({
    List<Booking>? items,
    String? cancellingId,
    bool clearCancelling = false,
  }) {
    return MyTripsLoaded(
      items: items ?? this.items,
      cancellingId: clearCancelling ? null : (cancellingId ?? this.cancellingId),
    );
  }

  @override
  List<Object?> get props => [items, cancellingId];
}

final class MyTripsError extends MyTripsState {
  const MyTripsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
