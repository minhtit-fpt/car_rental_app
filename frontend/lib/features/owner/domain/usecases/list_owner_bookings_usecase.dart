import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/owner/domain/entities/owner_booking.dart';
import 'package:frontend/features/owner/domain/repositories/owner_repository.dart';

/// Đơn đặt trên các xe của chủ xe (`GET /api/owner/bookings`).
class ListOwnerBookingsUseCase {
  const ListOwnerBookingsUseCase(this._repository);

  final OwnerRepository _repository;

  Future<List<OwnerBooking>> call({
    BookingStatus? status,
    int page = 1,
    int limit = 20,
  }) => _repository.listBookings(status: status, page: page, limit: limit);
}
