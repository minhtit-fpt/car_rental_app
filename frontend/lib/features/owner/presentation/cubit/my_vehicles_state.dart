import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

sealed class MyVehiclesState {
  const MyVehiclesState();
}

final class MyVehiclesLoading extends MyVehiclesState {
  const MyVehiclesLoading();
}

final class MyVehiclesLoaded extends MyVehiclesState {
  const MyVehiclesLoaded(this.vehicles);
  final List<Vehicle> vehicles;
}

final class MyVehiclesError extends MyVehiclesState {
  const MyVehiclesError(this.message);
  final String message;
}
