/// Một điểm toạ độ xe tại một thời điểm.
class TrackingPoint {
  const TrackingPoint({
    required this.lat,
    required this.lng,
    required this.recordedAt,
    this.speedKmh,
  });

  final double lat;
  final double lng;
  final double? speedKmh;
  final DateTime recordedAt;
}

/// Vị trí realtime của một xe: điểm mới nhất + trail (cũ→mới) để vẽ lộ trình.
class TrackingSnapshot {
  const TrackingSnapshot({
    required this.vehicleId,
    required this.latest,
    required this.trail,
    this.bookingId,
  });

  final String vehicleId;
  final String? bookingId;
  final TrackingPoint latest;
  final List<TrackingPoint> trail;
}

/// Vị trí mới nhất một xe đang trong chuyến (cho map admin).
class ActiveVehicleLocation {
  const ActiveVehicleLocation({
    required this.vehicleId,
    required this.title,
    required this.lat,
    required this.lng,
    required this.recordedAt,
    this.bookingId,
    this.speedKmh,
  });

  final String vehicleId;
  final String? bookingId;
  final String title;
  final double lat;
  final double lng;
  final double? speedKmh;
  final DateTime recordedAt;
}
