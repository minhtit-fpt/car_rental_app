import 'package:geolocator/geolocator.dart';

import 'package:frontend/core/location/app_geo.dart';

/// Lấy vị trí hiện tại của người dùng cho tính năng bản đồ. Bọc `geolocator`
/// sau một interface để cubit/test thay bằng fake không cần platform.
abstract interface class LocationService {
  /// Vị trí hiện tại, hoặc [AppGeo.defaultCenter] khi tắt định vị / từ chối
  /// quyền / lỗi — luôn trả về toạ độ để bản đồ có tâm để mở.
  Future<GeoPoint> currentLocation();

  /// Người dùng đã cấp quyền vị trí hay chưa (để UI hiện gợi ý bật định vị).
  Future<bool> hasPermission();
}

/// Triển khai thật trên `geolocator`. Mọi nhánh lỗi đều fallback về tâm mặc định
/// thay vì ném — bản đồ vẫn dùng được khi không có định vị.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<bool> hasPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<GeoPoint> currentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return AppGeo.defaultCenter;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return AppGeo.defaultCenter;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return GeoPoint(position.latitude, position.longitude);
    } on Exception {
      // Định vị có thể timeout/lỗi platform — luôn fallback an toàn.
      return AppGeo.defaultCenter;
    }
  }
}
