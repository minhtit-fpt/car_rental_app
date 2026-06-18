import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/owner/presentation/cubit/my_vehicles_state.dart';
import 'package:frontend/features/vehicle/domain/usecases/list_vehicles_usecase.dart';

export 'package:frontend/features/owner/presentation/cubit/my_vehicles_state.dart';

/// Xe của chủ xe hiện tại (`GET /api/vehicles?mine=true`).
class MyVehiclesCubit extends Cubit<MyVehiclesState> {
  MyVehiclesCubit({required ListVehiclesUseCase listVehicles})
    : _listVehicles = listVehicles,
      super(const MyVehiclesLoading());

  final ListVehiclesUseCase _listVehicles;

  Future<void> load() async {
    emit(const MyVehiclesLoading());
    try {
      emit(MyVehiclesLoaded(await _listVehicles(mine: true, limit: 100)));
    } on ApiException catch (e) {
      emit(MyVehiclesError(e.message));
    }
  }
}
