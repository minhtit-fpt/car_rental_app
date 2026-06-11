import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/usecases/get_vehicles_usecase.dart';
import 'package:frontend/features/vehicle/domain/vehicle_exception.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_state.dart';

class VehicleListCubit extends Cubit<VehicleListState> {
  VehicleListCubit(this._getVehicles) : super(const VehicleListLoading());

  final GetVehiclesUseCase _getVehicles;

  VehicleType? _type;
  bool _electricOnly = false;

  Future<void> load() => _fetch();

  Future<void> setType(VehicleType? type) {
    _type = type;
    return _fetch();
  }

  Future<void> toggleElectric(bool electricOnly) {
    _electricOnly = electricOnly;
    return _fetch();
  }

  Future<void> _fetch() async {
    emit(const VehicleListLoading());
    try {
      final items = await _getVehicles(
        type: _type,
        isElectric: _electricOnly ? true : null,
      );
      emit(
        VehicleListLoaded(
          items: items,
          type: _type,
          electricOnly: _electricOnly,
        ),
      );
    } on VehicleException catch (e) {
      emit(
        VehicleListError(
          message: e.message,
          type: _type,
          electricOnly: _electricOnly,
        ),
      );
    }
  }
}
