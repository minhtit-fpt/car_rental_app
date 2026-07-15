import 'package:frontend/features/booking/domain/entities/booking.dart';

sealed class MyTripsState {
  const MyTripsState();
}

final class MyTripsLoading extends MyTripsState {
  const MyTripsLoading();
}

final class MyTripsLoaded extends MyTripsState {
  const MyTripsLoaded(this.bookings, {this.cancellingId, this.actionError});

  final List<Booking> bookings;

  /// Id đơn đang trong quá trình huỷ (để khoá nút + hiện loading).
  final String? cancellingId;

  /// Lỗi của thao tác (vd huỷ đơn) — hiện qua SnackBar, KHÔNG thay cả danh sách.
  final String? actionError;
}

final class MyTripsError extends MyTripsState {
  const MyTripsError(this.message);
  final String message;
}
