import 'package:frontend/features/booking/domain/entities/booking.dart';

/// Tham số tạo đơn — usecase chuyển sang đây trước khi xuống datasource.
class CreateBookingParams {
  const CreateBookingParams({
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    this.deliveryRequested = false,
  });

  final String vehicleId;
  final DateTime startTime;
  final DateTime endTime;
  final bool deliveryRequested;
}

abstract interface class BookingRepository {
  Future<Booking> create(CreateBookingParams params);

  Future<List<Booking>> getMyBookings({
    BookingStatus? status,
    int page,
    int limit,
  });

  Future<Booking> cancel(String id);
}
