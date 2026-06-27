import 'package:frontend/core/location/app_geo.dart';
import 'package:frontend/features/map/presentation/vehicle_marker.dart';

sealed class MapState {
  const MapState();
}

final class MapLoading extends MapState {
  const MapLoading();
}

/// Bộ lọc xe trên bản đồ (client-side trên danh sách đã quét, ≤50 xe).
class MapFilter {
  const MapFilter({this.types = const {}});

  /// Loại xe được chọn (rỗng = hiện tất cả).
  final Set<String> types;

  bool get isActive => types.isNotEmpty;

  bool matches(VehicleMarker marker) =>
      types.isEmpty || types.contains(marker.type);

  MapFilter toggleType(String type) {
    final next = Set<String>.from(types);
    if (!next.add(type)) next.remove(type);
    return MapFilter(types: next);
  }
}

final class MapLoaded extends MapState {
  const MapLoaded({
    required this.center,
    required this.allMarkers,
    this.filter = const MapFilter(),
  });

  /// Tâm bản đồ = vị trí người dùng (hoặc tâm mặc định khi không có định vị).
  final GeoPoint center;

  /// Toàn bộ xe quét được; [markers] là phần đã lọc để hiển thị.
  final List<VehicleMarker> allMarkers;
  final MapFilter filter;

  List<VehicleMarker> get markers =>
      filter.isActive ? allMarkers.where(filter.matches).toList() : allMarkers;

  /// Các loại xe có mặt trong vùng quét — để dựng chip lọc động.
  List<String> get availableTypes =>
      (allMarkers.map((m) => m.type).toSet().toList())..sort();

  MapLoaded copyWith({MapFilter? filter}) => MapLoaded(
    center: center,
    allMarkers: allMarkers,
    filter: filter ?? this.filter,
  );
}

final class MapError extends MapState {
  const MapError(this.message);
  final String message;
}
