import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/vehicle/domain/usecases/list_nearby_vehicles_usecase.dart';
import 'package:frontend/features/vehicle/domain/usecases/list_vehicles_usecase.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_state.dart';

export 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_state.dart';

class VehicleListCubit extends Cubit<VehicleListState> {
  VehicleListCubit({
    required ListVehiclesUseCase listVehicles,
    required ListNearbyVehiclesUseCase listNearbyVehicles,
  }) : _listVehicles = listVehicles,
       _listNearbyVehicles = listNearbyVehicles,
       super(const VehicleListLoading());

  final ListVehiclesUseCase _listVehicles;
  final ListNearbyVehiclesUseCase _listNearbyVehicles;

  Future<void> load({bool? isElectric}) async {
    emit(const VehicleListLoading());
    try {
      final vehicles = await _listVehicles(isElectric: isElectric);
      emit(VehicleListLoaded(vehicles));
    } on ApiException catch (e) {
      emit(VehicleListError(e.message));
    }
  }

  /// Lọc xe theo thành phố: tải xe quanh toạ độ tâm thành phố đã chọn.
  Future<void> loadNearby({required double lat, required double lng}) async {
    emit(const VehicleListLoading());
    try {
      final vehicles = await _listNearbyVehicles(lat: lat, lng: lng);
      emit(VehicleListLoaded(vehicles));
    } on ApiException catch (e) {
      emit(VehicleListError(e.message));
    }
  }
}
