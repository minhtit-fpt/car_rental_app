import 'package:frontend/features/owner/domain/entities/owner_booking.dart';

sealed class OwnerBookingsState {
  const OwnerBookingsState();
}

final class OwnerBookingsLoading extends OwnerBookingsState {
  const OwnerBookingsLoading();
}

final class OwnerBookingsLoaded extends OwnerBookingsState {
  const OwnerBookingsLoaded(this.bookings, {this.actingId});

  final List<OwnerBooking> bookings;

  /// Id đơn đang được phê duyệt/từ chối (để khoá nút + hiện loading).
  final String? actingId;

  /// Các đơn còn chờ chủ xe xử lý.
  List<OwnerBooking> get pending =>
      bookings.where((b) => b.isPending).toList(growable: false);

  OwnerBookingsLoaded copyWith({
    List<OwnerBooking>? bookings,
    String? actingId,
  }) => OwnerBookingsLoaded(bookings ?? this.bookings, actingId: actingId);
}

final class OwnerBookingsError extends OwnerBookingsState {
  const OwnerBookingsError(this.message);
  final String message;
}
