import 'package:frontend/features/booking/domain/entities/booking.dart';

/// Một khoảng thời gian xe đã bị giữ chỗ (suy ra từ đơn đặt).
class BookedInterval {
  const BookedInterval({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;

  /// Có chồng lên ngày [day] (so theo ngày, bỏ qua giờ) hay không.
  bool coversDay(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return startTime.isBefore(dayEnd) && endTime.isAfter(dayStart);
  }
}

/// Lịch bận của một xe — phản chiếu `VehicleAvailability` của backend.
class VehicleAvailability {
  const VehicleAvailability({required this.vehicleId, required this.bookings});

  final String vehicleId;
  final List<BookedInterval> bookings;
}
