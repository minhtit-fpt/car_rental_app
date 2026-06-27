import 'package:frontend/features/booking/domain/entities/booking.dart';

sealed class MyTripsState {
  const MyTripsState();
}

final class MyTripsLoading extends MyTripsState {
  const MyTripsLoading();
}

final class MyTripsLoaded extends MyTripsState {
  const MyTripsLoaded(this.bookings, {this.cancellingId});

  final List<Booking> bookings;

  /// Id đơn đang trong quá trình huỷ (để khoá nút + hiện loading).
  final String? cancellingId;

  MyTripsLoaded copyWith({List<Booking>? bookings, String? cancellingId}) =>
      MyTripsLoaded(bookings ?? this.bookings, cancellingId: cancellingId);
}

final class MyTripsError extends MyTripsState {
  const MyTripsError(this.message);
  final String message;
}
