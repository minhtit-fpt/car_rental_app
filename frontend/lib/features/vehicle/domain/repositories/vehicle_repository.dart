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

  Future<List<Vehicle>> nearbyVehicles({
    required double lat,
    required double lng,
    int radius,
    int limit,
  });
}
