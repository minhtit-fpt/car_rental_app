import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/location/app_geo.dart';
import 'package:frontend/core/location/location_service.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/map/presentation/cubit/map_state.dart';
import 'package:frontend/features/map/presentation/vehicle_marker.dart';
import 'package:frontend/features/vehicle/domain/usecases/list_nearby_vehicles_usecase.dart';

export 'package:frontend/features/map/presentation/cubit/map_state.dart';

/// Điều phối màn bản đồ: lấy vị trí hiện tại → quét xe quanh đó → dựng marker.
class MapCubit extends Cubit<MapState> {
  MapCubit({
    required LocationService locationService,
    required ListNearbyVehiclesUseCase listNearbyVehicles,
  }) : _locationService = locationService,
       _listNearbyVehicles = listNearbyVehicles,
       super(const MapLoading());

  final LocationService _locationService;
  final ListNearbyVehiclesUseCase _listNearbyVehicles;

  /// Mở/refresh bản đồ. [LocationService] luôn trả toạ độ (fallback tâm mặc
  /// định) nên phần định vị không ném; chỉ lỗi mạng mới chuyển sang [MapError].
  Future<void> load() async {
    emit(const MapLoading());
    final center = await _locationService.currentLocation();
    try {
      final vehicles = await _listNearbyVehicles(
        lat: center.latitude,
        lng: center.longitude,
        radius: AppGeo.nearbyRadiusMeters,
      );
      emit(MapLoaded(center: center, markers: vehicleMarkers(vehicles)));
    } on ApiException catch (e) {
      emit(MapError(e.message));
    }
  }
}
