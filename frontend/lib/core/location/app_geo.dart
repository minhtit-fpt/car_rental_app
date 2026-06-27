/// Toạ độ địa lý thuần Dart (không phụ thuộc Google Maps / geolocator) để tầng
/// domain và test dùng được mà không cần platform. Map widget tự đổi sang
/// `LatLng` ở tầng presentation.
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';
}

/// Hằng số vị trí mặc định khi chưa có quyền/định vị thất bại.
abstract final class AppGeo {
  /// Tâm Hà Nội (Hồ Gươm) — fallback mặc định cho thị trường VN.
  static const GeoPoint defaultCenter = GeoPoint(21.0278, 105.8342);

  /// Zoom mặc định khi mở bản đồ ở mức thành phố.
  static const double cityZoom = 12.5;

  /// Bán kính (mét) quét xe quanh tâm — đủ phủ một đô thị.
  static const int nearbyRadiusMeters = 50000;

  /// Tâm các thành phố lớn (lowercase, không dấu hoá đơn giản) để suy ra vị trí
  /// cho mini-map ở màn chi tiết khi backend chỉ trả tên thành phố, chưa có toạ độ.
  static const Map<String, GeoPoint> cityCenters = {
    'ha noi': GeoPoint(21.0278, 105.8342),
    'hanoi': GeoPoint(21.0278, 105.8342),
    'ho chi minh': GeoPoint(10.7769, 106.7009),
    'hcm': GeoPoint(10.7769, 106.7009),
    'sai gon': GeoPoint(10.7769, 106.7009),
    'da nang': GeoPoint(16.0544, 108.2022),
    'hai phong': GeoPoint(20.8449, 106.6881),
    'can tho': GeoPoint(10.0452, 105.7469),
    'nha trang': GeoPoint(12.2388, 109.1967),
    'hue': GeoPoint(16.4637, 107.5909),
    'da lat': GeoPoint(11.9404, 108.4583),
    'vung tau': GeoPoint(10.4114, 107.1362),
  };

  /// Suy ra toạ độ tâm từ tên thành phố (bỏ dấu tiếng Việt + chuẩn hoá khoảng
  /// trắng). Trả [defaultCenter] khi không khớp để mini-map luôn có gì để hiển thị.
  static GeoPoint cityCenterOf(String? city) {
    if (city == null) return defaultCenter;
    final key = _normalize(city);
    if (key.isEmpty) return defaultCenter;
    return cityCenters[key] ?? defaultCenter;
  }

  /// Mỗi nhóm: ký tự gốc → chuỗi mọi biến thể có dấu của nó (lowercase).
  static const Map<String, String> _diacriticGroups = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };

  static String _normalize(String input) {
    var lower = input.toLowerCase().trim();
    _diacriticGroups.forEach((base, variants) {
      for (final ch in variants.split('')) {
        lower = lower.replaceAll(ch, base);
      }
    });
    return lower.replaceAll(RegExp(r'\s+'), ' ');
  }
}
