import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';

class GetVehiclesUseCase {
  const GetVehiclesUseCase(this._repository);

  final VehicleRepository _repository;

  Future<List<Vehicle>> call({
    VehicleType? type,
    bool? isElectric,
    int page = 1,
    int limit = 20,
  }) =>
      _repository.getVehicles(
        type: type,
        isElectric: isElectric,
        page: page,
        limit: limit,
      );
}
