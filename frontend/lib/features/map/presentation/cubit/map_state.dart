import 'package:frontend/core/location/app_geo.dart';
import 'package:frontend/features/map/presentation/vehicle_marker.dart';

sealed class MapState {
  const MapState();
}

final class MapLoading extends MapState {
  const MapLoading();
}

final class MapLoaded extends MapState {
  const MapLoaded({required this.center, required this.markers});

  /// Tâm bản đồ = vị trí người dùng (hoặc tâm mặc định khi không có định vị).
  final GeoPoint center;
  final List<VehicleMarker> markers;
}

final class MapError extends MapState {
  const MapError(this.message);
  final String message;
}
