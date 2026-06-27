import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/owner/presentation/cubit/my_vehicles_state.dart';
import 'package:frontend/features/vehicle/domain/usecases/delete_vehicle_usecase.dart';
import 'package:frontend/features/vehicle/domain/usecases/list_vehicles_usecase.dart';

export 'package:frontend/features/owner/presentation/cubit/my_vehicles_state.dart';

/// Xe của chủ xe hiện tại (`GET /api/vehicles?mine=true`).
class MyVehiclesCubit extends Cubit<MyVehiclesState> {
  MyVehiclesCubit({
    required ListVehiclesUseCase listVehicles,
    required DeleteVehicleUseCase deleteVehicle,
  }) : _listVehicles = listVehicles,
       _deleteVehicle = deleteVehicle,
       super(const MyVehiclesLoading());

  final ListVehiclesUseCase _listVehicles;
  final DeleteVehicleUseCase _deleteVehicle;

  Future<void> load() async {
    emit(const MyVehiclesLoading());
    try {
      emit(MyVehiclesLoaded(await _listVehicles(mine: true, limit: 100)));
    } on ApiException catch (e) {
      emit(MyVehiclesError(e.message));
    }
  }

  /// Gỡ xe. Trả về `null` khi thành công (đã loại khỏi danh sách hiện tại),
  /// hoặc thông báo lỗi khi thất bại (giữ nguyên danh sách).
  Future<String?> delete(String id) async {
    try {
      await _deleteVehicle(id);
      final current = state;
      if (current is MyVehiclesLoaded) {
        emit(
          MyVehiclesLoaded(
            current.vehicles.where((v) => v.id != id).toList(growable: false),
          ),
        );
      }
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
