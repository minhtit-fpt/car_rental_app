import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';

class GetVehicleUseCase {
  const GetVehicleUseCase(this._repository);

  final VehicleRepository _repository;

  Future<Vehicle> call(String id) => _repository.getVehicle(id);
}
