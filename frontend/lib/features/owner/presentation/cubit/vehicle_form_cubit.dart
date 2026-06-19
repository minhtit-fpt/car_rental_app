import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/owner/presentation/cubit/vehicle_form_state.dart';
import 'package:frontend/features/vehicle/domain/usecases/create_vehicle_usecase.dart';
import 'package:frontend/features/vehicle/domain/usecases/update_vehicle_usecase.dart';

export 'package:frontend/features/owner/presentation/cubit/vehicle_form_state.dart';

/// Quản lý luồng đăng xe mới và chỉnh sửa xe của chủ xe.
class VehicleFormCubit extends Cubit<VehicleFormState> {
  VehicleFormCubit({
    required CreateVehicleUseCase createVehicle,
    required UpdateVehicleUseCase updateVehicle,
  }) : _createVehicle = createVehicle,
       _updateVehicle = updateVehicle,
       super(const VehicleFormIdle());

  final CreateVehicleUseCase _createVehicle;
  final UpdateVehicleUseCase _updateVehicle;

  Future<void> create({
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
        seats: seats,
        doors: doors,
        transmission: transmission,
        city: city,
      );
      emit(VehicleFormSuccess(vehicle));
    } on ApiException catch (e) {
      emit(VehicleFormError(e.message));
    }
  }

  /// Cập nhật xe đã có. `type` không đổi được (ràng buộc backend) nên không nhận.
  /// [lat]/[lng] để null nghĩa là giữ nguyên vị trí cũ (backend yêu cầu cặp
  /// toạ độ đi cùng nhau, nên truyền cả hai hoặc không truyền gì).
  Future<void> update(
    String id, {
    required String title,
    required double pricePerHour,
    required bool isElectric,
    required bool deliveryAvailable,
    int? seats,
    int? doors,
    String? transmission,
    String? city,
    double? lat,
    double? lng,
  }) async {
    if (state is VehicleFormSubmitting) return;
    emit(const VehicleFormSubmitting());
    try {
      final vehicle = await _updateVehicle(
        id,
        title: title,
        pricePerHour: pricePerHour,
        isElectric: isElectric,
        deliveryAvailable: deliveryAvailable,
        seats: seats,
        doors: doors,
        transmission: transmission,
        city: city,
        lat: lat,
        lng: lng,
      );
      emit(VehicleFormSuccess(vehicle));
    } on ApiException catch (e) {
      emit(VehicleFormError(e.message));
    }
  }
}
