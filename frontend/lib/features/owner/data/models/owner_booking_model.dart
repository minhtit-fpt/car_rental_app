import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/owner/domain/entities/owner_booking.dart';

/// Ánh xạ JSON `OwnerBooking` của backend → entity.
abstract final class OwnerBookingModel {
  static OwnerBooking fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] as Map<String, dynamic>;
    final renter = json['renter'] as Map<String, dynamic>;
    return OwnerBooking(
      id: json['id'] as String,
      status: BookingStatus.fromApi(json['status'] as String?),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      deliveryRequested: json['deliveryRequested'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      vehicleId: vehicle['id'] as String,
      vehicleTitle: vehicle['title'] as String,
      vehicleType: vehicle['type'] as String,
      renterId: renter['id'] as String,
      renterPhone: renter['phone'] as String,
      renterEmail: renter['email'] as String?,
    );
  }
}
