import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

/// Hợp đồng domain cho dữ liệu xe (`/api/vehicles*`).
abstract interface class VehicleRepository {
  Future<List<Vehicle>> listVehicles({
    bool? isElectric,
    bool? available,
    num? minPrice,
    num? maxPrice,
    int page,
    int limit,
  });

  Future<Vehicle> getVehicle(String id);

  /// `POST /api/vehicles` — chủ xe đăng xe mới.
  Future<Vehicle> createVehicle({
    required String type,
    required String title,
    required double pricePerHour,
    required bool isElectric,
    required bool deliveryAvailable,
    required double lat,
    required double lng,
  });

  Future<List<Vehicle>> nearbyVehicles({
    required double lat,
    required double lng,
    int radius,
    int limit,
  });
}
