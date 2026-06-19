import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/owner/presentation/cubit/vehicle_form_state.dart';
import 'package:frontend/features/vehicle/domain/usecases/create_vehicle_usecase.dart';

export 'package:frontend/features/owner/presentation/cubit/vehicle_form_state.dart';

/// Quản lý luồng đăng xe mới của chủ xe.
class VehicleFormCubit extends Cubit<VehicleFormState> {
  VehicleFormCubit({required CreateVehicleUseCase createVehicle})
    : _createVehicle = createVehicle,
      super(const VehicleFormIdle());

  final CreateVehicleUseCase _createVehicle;

  Future<void> create({
    required String type,
    required String title,
    required double pricePerHour,
    required bool isElectric,
    required bool deliveryAvailable,
    required double lat,
    required double lng,
  }) async {
    if (state is VehicleFormSubmitting) return;
    emit(const VehicleFormSubmitting());
    try {
      final vehicle = await _createVehicle(
        type: type,
        title: title,
        pricePerHour: pricePerHour,
        isElectric: isElectric,
        deliveryAvailable: deliveryAvailable,
        lat: lat,
        lng: lng,
      );
      emit(VehicleFormSuccess(vehicle));
    } on ApiException catch (e) {
      emit(VehicleFormError(e.message));
    }
  }
}
