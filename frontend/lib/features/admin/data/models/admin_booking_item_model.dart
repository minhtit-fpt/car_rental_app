import 'package:frontend/features/admin/domain/entities/admin_booking_item.dart';

abstract final class AdminBookingItemModel {
  static AdminBookingItem fromJson(Map<String, dynamic> json) {
    return AdminBookingItem(
      id: json['id'] as String,
      vehicleTitle: json['vehicleTitle'] as String,
      status: json['status'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      paymentStatus: json['paymentStatus'] as String?,
    );
  }
}
