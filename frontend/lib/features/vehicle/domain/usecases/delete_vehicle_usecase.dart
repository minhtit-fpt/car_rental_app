import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';

/// Gỡ xe (`DELETE /api/vehicles/:id`). Chỉ chủ sở hữu xe gọi được.
class DeleteVehicleUseCase {
  const DeleteVehicleUseCase(this._repository);

  final VehicleRepository _repository;

  Future<void> call(String id) => _repository.deleteVehicle(id);
}
