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
    // Giữ bộ lọc qua mỗi lần refresh để không reset lựa chọn của người dùng.
    final previousFilter = switch (state) {
      MapLoaded(:final filter) => filter,
      _ => const MapFilter(),
    };
    emit(const MapLoading());
    final center = await _locationService.currentLocation();
    if (isClosed) return;
    try {
      final vehicles = await _listNearbyVehicles(
        lat: center.latitude,
        lng: center.longitude,
        radius: AppGeo.nearbyRadiusMeters,
      );
      if (isClosed) return;
      emit(
        MapLoaded(
          center: center,
          allMarkers: vehicleMarkers(vehicles),
          filter: previousFilter,
        ),
      );
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(MapError(e.message));
    }
  }

  /// Bật/tắt một loại xe trong bộ lọc (chỉ khi đã có dữ liệu bản đồ).
  void toggleType(String type) {
    final current = state;
    if (current is MapLoaded) {
      emit(current.copyWith(filter: current.filter.toggleType(type)));
    }
  }
}
