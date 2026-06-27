import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';

/// Cập nhật xe (`PATCH /api/vehicles/:id`). Chỉ chủ sở hữu xe gọi được.
class UpdateVehicleUseCase {
  const UpdateVehicleUseCase(this._repository);

  final VehicleRepository _repository;

  Future<Vehicle> call(
    String id, {
    String? title,
    double? pricePerHour,
    bool? isElectric,
    bool? deliveryAvailable,
    bool? isAvailable,
    int? seats,
    int? doors,
    String? transmission,
    String? city,
    double? lat,
    double? lng,
  }) => _repository.updateVehicle(
    id,
    title: title,
    pricePerHour: pricePerHour,
    isElectric: isElectric,
    deliveryAvailable: deliveryAvailable,
    isAvailable: isAvailable,
    seats: seats,
    doors: doors,
    transmission: transmission,
    city: city,
    lat: lat,
    lng: lng,
  );
}
