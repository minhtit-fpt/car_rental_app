import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';

class GetMyBookingsUseCase {
  const GetMyBookingsUseCase(this._repository);

  final BookingRepository _repository;

  Future<List<Booking>> call({
    BookingStatus? status,
    int page = 1,
    int limit = 20,
  }) =>
      _repository.getMyBookings(status: status, page: page, limit: limit);
}
