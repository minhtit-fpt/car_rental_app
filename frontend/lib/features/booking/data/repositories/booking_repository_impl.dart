import 'package:frontend/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:frontend/features/booking/data/models/booking_model.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  const BookingRepositoryImpl(this._remote);

  final BookingRemoteDataSource _remote;

  @override
  Future<Booking> createBooking({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
    bool deliveryRequested = false,
  }) async => BookingModel.fromJson(
    await _remote.create(
      vehicleId: vehicleId,
      startTime: startTime,
      endTime: endTime,
      deliveryRequested: deliveryRequested,
    ),
  );

  @override
  Future<List<Booking>> listBookings({
    BookingStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    final items = await _remote.list(
      status: _statusToApi(status),
      page: page,
      limit: limit,
    );
    return items
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Booking> getBooking(String id) async =>
      BookingModel.fromJson(await _remote.getById(id));

  @override
  Future<Booking> cancelBooking(String id) async =>
      BookingModel.fromJson(await _remote.cancel(id));

  /// Chuyển enum domain → chuỗi enum backend cho query lọc.
  static String? _statusToApi(BookingStatus? status) {
    switch (status) {
      case null:
      case BookingStatus.unknown:
        return null;
      case BookingStatus.pendingPayment:
        return 'PENDING_PAYMENT';
      case BookingStatus.confirmed:
        return 'CONFIRMED';
      case BookingStatus.inProgress:
        return 'IN_PROGRESS';
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
    }
  }
}
