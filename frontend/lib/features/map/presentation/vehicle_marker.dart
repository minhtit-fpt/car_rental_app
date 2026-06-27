import 'package:frontend/core/location/app_geo.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

/// Dữ liệu marker thuần Dart (không phụ thuộc Google Maps) để map mapping test
/// được. [MapScreen] đổi sang `Marker` của plugin ở tầng widget.
class VehicleMarker {
  const VehicleMarker({
    required this.vehicleId,
    required this.position,
    required this.title,
    required this.pricePerHour,
    required this.type,
  });

  final String vehicleId;
  final GeoPoint position;
  final String title;
  final double pricePerHour;
  final String type;

  @override
  bool operator ==(Object other) =>
      other is VehicleMarker &&
      other.vehicleId == vehicleId &&
      other.position == position &&
      other.title == title &&
      other.pricePerHour == pricePerHour &&
      other.type == type;

  @override
  int get hashCode =>
      Object.hash(vehicleId, position, title, pricePerHour, type);
}

/// Chuyển danh sách xe → marker, BỎ những xe thiếu toạ độ (list/detail không có
/// lat/lng nên không thể đặt lên bản đồ — chỉ endpoint `nearby` mới đủ dữ liệu).
List<VehicleMarker> vehicleMarkers(List<Vehicle> vehicles) {
  return [
    for (final v in vehicles)
      if (v.latitude != null && v.longitude != null)
        VehicleMarker(
          vehicleId: v.id,
          position: GeoPoint(v.latitude!, v.longitude!),
          title: v.title,
          pricePerHour: v.pricePerHour,
          type: v.type,
        ),
  ];
}
