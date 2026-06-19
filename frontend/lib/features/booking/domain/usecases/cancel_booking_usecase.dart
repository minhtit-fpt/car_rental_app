import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';

/// Huỷ một đơn đặt (`POST /api/bookings/:id/cancel`). Trả về đơn đã cập nhật.
class CancelBookingUseCase {
  const CancelBookingUseCase(this._repository);

  final BookingRepository _repository;

  Future<Booking> call(String id) => _repository.cancelBooking(id);
}
