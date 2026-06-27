import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/vehicle/domain/usecases/get_vehicle_availability_usecase.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_availability_state.dart';

export 'package:frontend/features/vehicle/presentation/cubit/vehicle_availability_state.dart';

/// Lịch bận của một xe (`GET /api/vehicles/:id/availability`).
class VehicleAvailabilityCubit extends Cubit<VehicleAvailabilityState> {
  VehicleAvailabilityCubit({
    required GetVehicleAvailabilityUseCase getAvailability,
  }) : _getAvailability = getAvailability,
       super(const VehicleAvailabilityLoading());

  final GetVehicleAvailabilityUseCase _getAvailability;

  Future<void> load(String vehicleId) async {
    emit(const VehicleAvailabilityLoading());
    try {
      emit(VehicleAvailabilityLoaded(await _getAvailability(vehicleId)));
    } on ApiException catch (e) {
      emit(VehicleAvailabilityError(e.message));
    }
  }
}
