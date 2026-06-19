import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';

/// Xe quanh một toạ độ (`GET /api/vehicles/nearby`). Dùng để lọc theo thành phố:
/// truyền toạ độ tâm thành phố + bán kính đủ phủ khu vực đô thị.
class ListNearbyVehiclesUseCase {
  const ListNearbyVehiclesUseCase(this._repository);

  final VehicleRepository _repository;

  Future<List<Vehicle>> call({
    required double lat,
    required double lng,
    int radius = 50000,
    int limit = 50,
  }) => _repository.nearbyVehicles(
    lat: lat,
    lng: lng,
    radius: radius,
    limit: limit,
  );
}
