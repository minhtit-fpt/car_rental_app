import 'package:frontend/features/tracking/domain/entities/tracking_snapshot.dart';

/// Ánh xạ JSON tracking của backend → entity.
abstract final class TrackingModel {
  static TrackingPoint pointFromJson(Map<String, dynamic> json) =>
      TrackingPoint(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        speedKmh: (json['speedKmh'] as num?)?.toDouble(),
        recordedAt: DateTime.parse(json['recordedAt'] as String),
      );

  static TrackingSnapshot snapshotFromJson(Map<String, dynamic> json) =>
      TrackingSnapshot(
        vehicleId: json['vehicleId'] as String,
        bookingId: json['bookingId'] as String?,
        latest: pointFromJson(json['latest'] as Map<String, dynamic>),
        trail: (json['trail'] as List<dynamic>)
            .map((e) => pointFromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static ActiveVehicleLocation activeFromJson(Map<String, dynamic> json) =>
      ActiveVehicleLocation(
        vehicleId: json['vehicleId'] as String,
        bookingId: json['bookingId'] as String?,
        title: json['title'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        speedKmh: (json['speedKmh'] as num?)?.toDouble(),
        recordedAt: DateTime.parse(json['recordedAt'] as String),
      );
}
