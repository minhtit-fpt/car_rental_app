import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/tracking/domain/entities/tracking_snapshot.dart';
import 'package:frontend/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:frontend/features/tracking/domain/usecases/get_tracking_snapshot_usecase.dart';
import 'package:frontend/features/tracking/presentation/cubit/tracking_cubit.dart';
import 'package:frontend/features/tracking/presentation/cubit/tracking_state.dart';

class _FakeTrackingRepository implements TrackingRepository {
  TrackingSnapshot? result;
  Object? error;
  int calls = 0;

  @override
  Future<TrackingSnapshot> latest(String vehicleId, {int trail = 20}) async {
    calls++;
    if (error != null) throw error!;
    return result!;
  }

  @override
  Future<List<ActiveVehicleLocation>> active() async => const [];
}

TrackingSnapshot _snap() => TrackingSnapshot(
  vehicleId: 'veh-1',
  bookingId: 'bk-1',
  latest: TrackingPoint(
    lat: 21.0,
    lng: 105.0,
    recordedAt: DateTime(2026, 7, 13, 10),
  ),
  trail: const [],
);

void main() {
  late _FakeTrackingRepository repo;
  TrackingCubit build() =>
      TrackingCubit(getSnapshot: GetTrackingSnapshotUseCase(repo));

  setUp(() => repo = _FakeTrackingRepository());

  blocTest<TrackingCubit, TrackingState>(
    'emits Loaded after first poll tick',
    build: () {
      repo.result = _snap();
      return build();
    },
    act: (c) => c.start('veh-1'),
    wait: const Duration(milliseconds: 50),
    expect: () => [isA<TrackingLoading>(), isA<TrackingLoaded>()],
  );

  blocTest<TrackingCubit, TrackingState>(
    'emits Error when first tick fails',
    build: () {
      repo.error = const ApiException('boom');
      return build();
    },
    act: (c) => c.start('veh-1'),
    wait: const Duration(milliseconds: 50),
    expect: () => [isA<TrackingLoading>(), isA<TrackingError>()],
  );

  test('permanent error (403) after loaded stops polling and emits Error',
      () async {
    repo.result = _snap();
    final cubit = build();
    cubit.start('veh-1');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(cubit.state, isA<TrackingLoaded>());
    // Chuyến kết thúc → backend trả 403 TRACKING_UNAVAILABLE.
    repo.error = const ApiException('Xe không trong chuyến', statusCode: 403);
    await Future<void>.delayed(
      TrackingCubit.pollInterval + const Duration(milliseconds: 50),
    );
    expect(cubit.state, isA<TrackingError>());
    final callsAfterError = repo.calls;
    // Không poll thêm sau lỗi vĩnh viễn (không đóng băng, không hammer).
    await Future<void>.delayed(
      TrackingCubit.pollInterval + const Duration(milliseconds: 50),
    );
    expect(repo.calls, callsAfterError);
    await cubit.close();
  });

  test('close cancels polling (no further calls)', () async {
    repo.result = _snap();
    final cubit = build();
    cubit.start('veh-1');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final callsAtClose = repo.calls;
    await cubit.close();
    await Future<void>.delayed(
      TrackingCubit.pollInterval + const Duration(milliseconds: 50),
    );
    expect(repo.calls, callsAtClose); // không tick thêm sau close
  });
}
