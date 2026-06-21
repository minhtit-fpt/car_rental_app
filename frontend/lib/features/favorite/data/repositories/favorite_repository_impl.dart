import 'package:frontend/features/favorite/data/datasources/favorite_remote_datasource.dart';
import 'package:frontend/features/favorite/domain/repositories/favorite_repository.dart';
import 'package:frontend/features/vehicle/data/models/vehicle_model.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  const FavoriteRepositoryImpl(this._remote);

  final FavoriteRemoteDataSource _remote;

  @override
  Future<List<Vehicle>> list() async {
    final data = await _remote.list();
    return data
        .map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> add(String vehicleId) => _remote.add(vehicleId);

  @override
  Future<void> remove(String vehicleId) => _remote.remove(vehicleId);
}
