import 'package:frontend/features/tracking/data/datasources/tracking_remote_datasource.dart';
import 'package:frontend/features/tracking/data/models/tracking_snapshot_model.dart';
import 'package:frontend/features/tracking/domain/entities/tracking_snapshot.dart';
import 'package:frontend/features/tracking/domain/repositories/tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  const TrackingRepositoryImpl(this._remote);

  final TrackingRemoteDataSource _remote;

  @override
  Future<TrackingSnapshot> latest(String vehicleId, {int trail = 20}) async {
    final json = await _remote.latest(vehicleId, trail: trail);
    return TrackingModel.snapshotFromJson(json);
  }

  @override
  Future<List<ActiveVehicleLocation>> active() async {
    final list = await _remote.active();
    return list
        .map((e) => TrackingModel.activeFromJson(e as Map<String, dynamic>))
        .toList();
  }
}
