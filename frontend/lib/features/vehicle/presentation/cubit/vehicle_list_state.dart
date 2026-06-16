import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

sealed class VehicleListState {
  const VehicleListState();
}

final class VehicleListLoading extends VehicleListState {
  const VehicleListLoading();
}

final class VehicleListLoaded extends VehicleListState {
  const VehicleListLoaded(this.vehicles);
  final List<Vehicle> vehicles;
}

final class VehicleListError extends VehicleListState {
  const VehicleListError(this.message);
  final String message;
}
