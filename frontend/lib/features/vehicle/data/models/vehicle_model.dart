import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

/// Ánh xạ JSON `PublicVehicle` / `NearbyVehicle` của backend → [Vehicle].
abstract final class VehicleModel {
  static Vehicle fromJson(Map<String, dynamic> json) => Vehicle(
    id: json['id'] as String,
    ownerId: json['ownerId'] as String,
    ownerName: json['ownerName'] as String?,
    type: json['type'] as String,
    title: json['title'] as String,
    pricePerHour: (json['pricePerHour'] as num).toDouble(),
    isElectric: json['isElectric'] as bool? ?? false,
    isAvailable: json['isAvailable'] as bool? ?? true,
    deliveryAvailable: json['deliveryAvailable'] as bool? ?? false,
    seats: (json['seats'] as num?)?.toInt(),
    doors: (json['doors'] as num?)?.toInt(),
    transmission: json['transmission'] as String?,
    city: json['city'] as String?,
    // Chỉ endpoint `nearby` mới kèm khoảng cách.
    distanceMeters: (json['distanceMeters'] as num?)?.round(),
  );
}
