import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

abstract interface class VehicleRepository {
  Future<List<Vehicle>> getVehicles({
    VehicleType? type,
    bool? isElectric,
    int page,
    int limit,
  });

  Future<Vehicle> getById(String id);
}
