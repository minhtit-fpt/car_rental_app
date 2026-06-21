/// Một chiếc xe như backend trả về (`/api/vehicles*`).
///
/// Các trường lõi khớp đúng `PublicVehicle` của backend. Những thông tin mà
/// backend CHƯA cung cấp (đánh giá, tên chủ xe) để `null` thay vì bịa số —
/// UI tự ẩn khi thiếu. `pricePerDay`, `emoji`, `typeLabel`… là getter suy ra,
/// không phải dữ liệu thật từ server.
class Vehicle {
  const Vehicle({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.title,
    required this.pricePerHour,
    required this.isElectric,
    required this.isAvailable,
    required this.deliveryAvailable,
    this.seats,
    this.doors,
    this.transmission,
    this.city,
    this.rating,
    this.reviewCount,
    this.ownerName,
    this.location = '',
    this.distanceMeters,
  });

  final String id;
  final String ownerId;

  /// Enum backend: `CAR` | `MOTORBIKE` | `BICYCLE`.
  final String type;
  final String title;

  /// Giá thuê theo giờ (VND) — nguồn sự thật từ backend.
  final double pricePerHour;
  final bool isElectric;
  final bool isAvailable;
  final bool deliveryAvailable;

  // ── Thông số kỹ thuật (nullable — backend trả null nếu chưa nhập) ─────────
  final int? seats;
  final int? doors;

  /// `'AUTOMATIC'` | `'MANUAL'` | null.
  final String? transmission;

  /// Thành phố hiển thị (text thật từ backend), null nếu chưa nhập.
  final String? city;

  /// Chỉ có khi gọi `/api/vehicles/nearby` (mét). Null ở list/detail thường.
  final int? distanceMeters;

  // ── Thông tin tổng hợp backend chưa trả → null tới khi nối slice tương ứng.
  final double? rating;
  final int? reviewCount;
  final String? ownerName;
  final String location;

  // ── Getter hiển thị (suy ra, không bịa dữ liệu) ──────────────────────────

  /// Tên hiển thị = tiêu đề tin đăng.
  String get name => title;

  /// Giá/ngày quy theo đơn vị nghìn VND (K) để khớp formatter UI hiện có
  /// (vd: 50.000đ/giờ → 50000*24/1000 = 1200 → "1.2M VNĐ"/ngày).
  double get pricePerDay => pricePerHour * 24 / 1000;

  /// Có dữ liệu đánh giá thật để hiển thị hay không.
  bool get hasRating => rating != null && (reviewCount ?? 0) > 0;

  /// Nhãn hộp số tiếng Việt, null nếu chưa có dữ liệu.
  String? get transmissionLabel => switch (transmission) {
    'AUTOMATIC' => 'Tự động',
    'MANUAL' => 'Số sàn',
    _ => null,
  };

  String get emoji => switch (type) {
    'MOTORBIKE' => '🏍️',
    'BICYCLE' => '🚲',
    _ => '🚗',
  };

  /// Nhãn loại xe tiếng Việt.
  String get typeLabel => switch (type) {
    'MOTORBIKE' => 'Xe máy',
    'BICYCLE' => 'Xe đạp',
    _ => 'Ô tô',
  };
}
