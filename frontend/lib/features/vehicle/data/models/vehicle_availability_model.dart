import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle_availability.dart';

/// Ánh xạ JSON `VehicleAvailability` của backend → entity.
abstract final class VehicleAvailabilityModel {
  static VehicleAvailability fromJson(Map<String, dynamic> json) {
    final raw = (json['bookings'] as List<dynamic>? ?? const []);
    final bookings = raw
        .map((e) => e as Map<String, dynamic>)
        .map(
          (b) => BookedInterval(
            id: b['id'] as String,
            startTime: DateTime.parse(b['startTime'] as String),
            endTime: DateTime.parse(b['endTime'] as String),
            status: BookingStatus.fromApi(b['status'] as String?),
          ),
        )
        .toList(growable: false);
    return VehicleAvailability(
      vehicleId: json['vehicleId'] as String,
      bookings: bookings,
    );
  }
}
