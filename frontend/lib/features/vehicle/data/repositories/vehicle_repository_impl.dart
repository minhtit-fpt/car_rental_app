import 'package:frontend/features/vehicle/data/datasources/vehicle_remote_datasource.dart';
import 'package:frontend/features/vehicle/data/models/vehicle_model.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  const VehicleRepositoryImpl(this._remote);

  final VehicleRemoteDataSource _remote;

  @override
  Future<List<Vehicle>> listVehicles({
    bool? isElectric,
    bool? available,
    num? minPrice,
    num? maxPrice,
    int page = 1,
    int limit = 20,
  }) async {
    final items = await _remote.list(
      isElectric: isElectric,
      available: available,
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: page,
      limit: limit,
    );
    return items
        .map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Vehicle> getVehicle(String id) async =>
      VehicleModel.fromJson(await _remote.getById(id));

  @override
  Future<List<Vehicle>> nearbyVehicles({
    required double lat,
    required double lng,
    int radius = 5000,
    int limit = 20,
  }) async {
    final items = await _remote.nearby(
      lat: lat,
      lng: lng,
      radius: radius,
      limit: limit,
    );
    return items
        .map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
