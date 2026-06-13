import 'package:frontend/features/vehicle/data/datasources/vehicle_remote_datasource.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  const VehicleRepositoryImpl(this._remote);

  final VehicleRemoteDataSource _remote;

  @override
  Future<List<Vehicle>> getVehicles({
    VehicleType? type,
    bool? isElectric,
    int page = 1,
    int limit = 20,
  }) =>
      _remote.getVehicles(
        type: type,
        isElectric: isElectric,
        page: page,
        limit: limit,
      );

  @override
  Future<Vehicle> getById(String id) => _remote.getById(id);
}
