import 'package:frontend/features/booking/domain/entities/booking.dart';

/// Map JSON từ backend → entity Booking.
Booking bookingFromJson(Map<String, dynamic> json) {
  return Booking(
    id: json['id'] as String,
    vehicleId: json['vehicleId'] as String,
    renterId: json['renterId'] as String,
    status: bookingStatusFromWire(json['status'] as String?),
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: DateTime.parse(json['endTime'] as String),
    totalPrice: (json['totalPrice'] as num).toDouble(),
    deliveryRequested: json['deliveryRequested'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
