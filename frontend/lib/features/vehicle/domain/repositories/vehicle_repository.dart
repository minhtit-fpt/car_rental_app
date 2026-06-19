import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle_availability.dart';

/// Hợp đồng domain cho dữ liệu xe (`/api/vehicles*`).
abstract interface class VehicleRepository {
  Future<List<Vehicle>> listVehicles({
    bool? isElectric,
    bool? available,
    num? minPrice,
    num? maxPrice,
    bool? mine,
    int page,
    int limit,
  });

  Future<Vehicle> getVehicle(String id);

  /// `GET /api/vehicles/:id/availability` — lịch bận của xe.
  Future<VehicleAvailability> getAvailability(String id);

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
