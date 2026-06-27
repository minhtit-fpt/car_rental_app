import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';

/// Lấy danh sách đơn đặt của chính người dùng (`GET /api/bookings`).
class ListBookingsUseCase {
  const ListBookingsUseCase(this._repository);

  final BookingRepository _repository;

  Future<List<Booking>> call({
    BookingStatus? status,
    int page = 1,
    int limit = 20,
  }) => _repository.listBookings(status: status, page: page, limit: limit);
}
