import 'package:frontend/features/tracking/domain/entities/tracking_snapshot.dart';
import 'package:frontend/features/tracking/domain/repositories/tracking_repository.dart';

class GetTrackingSnapshotUseCase {
  const GetTrackingSnapshotUseCase(this._repository);

  final TrackingRepository _repository;

  Future<TrackingSnapshot> call(String vehicleId, {int trail = 20}) =>
      _repository.latest(vehicleId, trail: trail);
}

class GetActiveTrackingUseCase {
  const GetActiveTrackingUseCase(this._repository);

  final TrackingRepository _repository;

  Future<List<ActiveVehicleLocation>> call() => _repository.active();
}
