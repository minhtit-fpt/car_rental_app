import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';

class ListVehiclesUseCase {
  const ListVehiclesUseCase(this._repository);

  final VehicleRepository _repository;

  Future<List<Vehicle>> call({
    bool? isElectric,
    bool? available,
    num? minPrice,
    num? maxPrice,
    bool? mine,
    int page = 1,
    int limit = 20,
  }) => _repository.listVehicles(
    isElectric: isElectric,
    available: available,
    minPrice: minPrice,
    maxPrice: maxPrice,
    mine: mine,
    page: page,
    limit: limit,
  );
}
