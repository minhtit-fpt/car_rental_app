import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';

/// Đăng xe mới (`POST /api/vehicles`). Chỉ chủ xe (role OWNER) gọi được.
class CreateVehicleUseCase {
  const CreateVehicleUseCase(this._repository);

  final VehicleRepository _repository;

  Future<Vehicle> call({
    required String type,
    required String title,
    required double pricePerHour,
    required bool isElectric,
    required bool deliveryAvailable,
    required double lat,
    required double lng,
  }) => _repository.createVehicle(
    type: type,
    title: title,
    pricePerHour: pricePerHour,
    isElectric: isElectric,
    deliveryAvailable: deliveryAvailable,
    lat: lat,
    lng: lng,
  );
}
