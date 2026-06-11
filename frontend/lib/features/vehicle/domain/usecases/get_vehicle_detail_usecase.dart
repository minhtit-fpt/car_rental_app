import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';

class GetVehicleDetailUseCase {
  const GetVehicleDetailUseCase(this._repository);

  final VehicleRepository _repository;

  Future<Vehicle> call(String id) => _repository.getById(id);
}
