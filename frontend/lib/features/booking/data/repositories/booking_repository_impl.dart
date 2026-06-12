import 'package:frontend/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  const BookingRepositoryImpl(this._remote);

  final BookingRemoteDataSource _remote;

  @override
  Future<Booking> create(CreateBookingParams params) =>
      _remote.create(params);

  @override
  Future<List<Booking>> getMyBookings({
    BookingStatus? status,
    int page = 1,
    int limit = 20,
  }) =>
      _remote.getMyBookings(status: status, page: page, limit: limit);

  @override
  Future<Booking> cancel(String id) => _remote.cancel(id);
}
