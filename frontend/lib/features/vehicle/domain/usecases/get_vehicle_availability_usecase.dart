import 'package:frontend/features/vehicle/domain/entities/vehicle_availability.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';

/// Lấy lịch bận của một xe (`GET /api/vehicles/:id/availability`).
class GetVehicleAvailabilityUseCase {
  const GetVehicleAvailabilityUseCase(this._repository);

  final VehicleRepository _repository;

  Future<VehicleAvailability> call(String id) =>
      _repository.getAvailability(id);
}
