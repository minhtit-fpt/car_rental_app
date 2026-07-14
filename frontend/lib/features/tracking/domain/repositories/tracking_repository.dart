import 'package:frontend/features/tracking/domain/entities/tracking_snapshot.dart';

abstract interface class TrackingRepository {
  Future<TrackingSnapshot> latest(String vehicleId, {int trail});
  Future<List<ActiveVehicleLocation>> active();
}
