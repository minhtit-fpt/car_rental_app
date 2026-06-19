import 'package:frontend/features/vehicle/domain/entities/vehicle_availability.dart';

sealed class VehicleAvailabilityState {
  const VehicleAvailabilityState();
}

final class VehicleAvailabilityLoading extends VehicleAvailabilityState {
  const VehicleAvailabilityLoading();
}

final class VehicleAvailabilityLoaded extends VehicleAvailabilityState {
  const VehicleAvailabilityLoaded(this.availability);
  final VehicleAvailability availability;
}

final class VehicleAvailabilityError extends VehicleAvailabilityState {
  const VehicleAvailabilityError(this.message);
  final String message;
}
