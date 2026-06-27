import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

sealed class VehicleFormState {
  const VehicleFormState();
}

final class VehicleFormIdle extends VehicleFormState {
  const VehicleFormIdle();
}

final class VehicleFormSubmitting extends VehicleFormState {
  const VehicleFormSubmitting();
}

final class VehicleFormSuccess extends VehicleFormState {
  const VehicleFormSuccess(this.vehicle);
  final Vehicle vehicle;
}

final class VehicleFormError extends VehicleFormState {
  const VehicleFormError(this.message);
  final String message;
}
