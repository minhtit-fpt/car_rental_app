import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

/// Map JSON từ backend → entity Vehicle.
Vehicle vehicleFromJson(Map<String, dynamic> json) {
  return Vehicle(
    id: json['id'] as String,
    ownerId: json['ownerId'] as String,
    type: vehicleTypeFromWire(json['type'] as String?),
    title: json['title'] as String,
    pricePerHour: (json['pricePerHour'] as num).toDouble(),
    isElectric: json['isElectric'] as bool? ?? false,
    isAvailable: json['isAvailable'] as bool? ?? true,
    deliveryAvailable: json['deliveryAvailable'] as bool? ?? false,
  );
}
