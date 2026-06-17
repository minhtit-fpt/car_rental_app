import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/vehicle/domain/usecases/list_vehicles_usecase.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_state.dart';

export 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_state.dart';

class VehicleListCubit extends Cubit<VehicleListState> {
  VehicleListCubit({required ListVehiclesUseCase listVehicles})
    : _listVehicles = listVehicles,
      super(const VehicleListLoading());

  final ListVehiclesUseCase _listVehicles;

  Future<void> load({bool? isElectric}) async {
    emit(const VehicleListLoading());
    try {
      final vehicles = await _listVehicles(isElectric: isElectric);
      emit(VehicleListLoaded(vehicles));
    } on ApiException catch (e) {
      emit(VehicleListError(e.message));
    }
  }
}
