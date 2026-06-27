import 'package:frontend/features/vehicle/data/datasources/vehicle_remote_datasource.dart';
import 'package:frontend/features/vehicle/data/models/vehicle_availability_model.dart';
import 'package:frontend/features/vehicle/data/models/vehicle_model.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle_availability.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  const VehicleRepositoryImpl(this._remote);

  final VehicleRemoteDataSource _remote;

  @override
  Future<List<Vehicle>> listVehicles({
    bool? isElectric,
    bool? available,
    num? minPrice,
    num? maxPrice,
    bool? mine,
    int page = 1,
    int limit = 20,
  }) async {
    final items = await _remote.list(
      isElectric: isElectric,
      available: available,
      minPrice: minPrice,
      maxPrice: maxPrice,
      mine: mine,
      page: page,
      limit: limit,
    );
    return items
        .map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Vehicle> getVehicle(String id) async =>
      VehicleModel.fromJson(await _remote.getById(id));

  @override
  Future<VehicleAvailability> getAvailability(String id) async =>
      VehicleAvailabilityModel.fromJson(await _remote.availability(id));

  @override
  Future<Vehicle> createVehicle({
    required String type,
    required String title,
    required double pricePerHour,
    required bool isElectric,
    required bool deliveryAvailable,
    required double lat,
    required double lng,
    int? seats,
    int? doors,
    String? transmission,
    String? city,
  }) async => VehicleModel.fromJson(
    await _remote.create(
      type: type,
      title: title,
      pricePerHour: pricePerHour,
      isElectric: isElectric,
      deliveryAvailable: deliveryAvailable,
      lat: lat,
      lng: lng,
      seats: seats,
      doors: doors,
      transmission: transmission,
      city: city,
    ),
  );

  @override
  Future<Vehicle> updateVehicle(
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
  }) async => VehicleModel.fromJson(
    await _remote.update(
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
    ),
  );

  @override
  Future<void> deleteVehicle(String id) => _remote.delete(id);

  @override
  Future<List<Vehicle>> nearbyVehicles({
    required double lat,
    required double lng,
    int radius = 5000,
    int limit = 20,
  }) async {
    final items = await _remote.nearby(
      lat: lat,
      lng: lng,
      radius: radius,
      limit: limit,
    );
    return items
        .map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
