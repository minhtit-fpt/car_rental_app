import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/location/app_geo.dart';
import 'package:frontend/core/location/location_service.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/map/presentation/cubit/map_cubit.dart';
import 'package:frontend/features/map/presentation/vehicle_marker.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:frontend/features/vehicle/domain/usecases/list_nearby_vehicles_usecase.dart';

/// Fake định vị: trả toạ độ cấu hình sẵn (không chạm platform).
class _FakeLocationService implements LocationService {
  _FakeLocationService(this._point);
  final GeoPoint _point;

  @override
  Future<GeoPoint> currentLocation() async => _point;

  @override
  Future<bool> hasPermission() async => true;
}

/// Fake repo chỉ phục vụ `nearbyVehicles`; các method khác không dùng tới.
class _FakeVehicleRepository implements VehicleRepository {
  List<Vehicle> nearbyResult = const [];
  Object? nearbyError;
  int? lastRadius;

  @override
  Future<List<Vehicle>> nearbyVehicles({
    required double lat,
    required double lng,
    int radius = 50000,
    int limit = 50,
  }) async {
    lastRadius = radius;
    if (nearbyError != null) throw nearbyError!;
    return nearbyResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used in test');
}

Vehicle _vehicle(String id, {double? lat, double? lng}) => Vehicle(
  id: id,
  ownerId: 'o1',
  type: 'CAR',
  title: 'Car $id',
  pricePerDay: 50000,
  isElectric: false,
  isAvailable: true,
  deliveryAvailable: false,
  latitude: lat,
  longitude: lng,
);

void main() {
  late _FakeVehicleRepository repo;
  late _FakeLocationService location;

  const here = GeoPoint(21.03, 105.85);

  MapCubit build() => MapCubit(
    locationService: location,
    listNearbyVehicles: ListNearbyVehiclesUseCase(repo),
  );

  setUp(() {
    repo = _FakeVehicleRepository();
    location = _FakeLocationService(here);
  });

  blocTest<MapCubit, MapState>(
    'emits Loaded centred on the current location with markers',
    build: build,
    act: (c) => c.load(),
    expect: () => [
      isA<MapLoading>(),
      isA<MapLoaded>()
          .having((s) => s.center, 'center', here)
          .having((s) => s.markers, 'markers', isEmpty),
    ],
  );

  blocTest<MapCubit, MapState>(
    'builds markers only for vehicles that carry coordinates',
    build: () {
      repo.nearbyResult = [
        _vehicle('a', lat: 21.0, lng: 105.0),
        _vehicle('b'), // dropped — no coords
      ];
      return build();
    },
    act: (c) => c.load(),
    expect: () => [
      isA<MapLoading>(),
      isA<MapLoaded>().having(
        (s) => s.markers.map((m) => m.vehicleId).toList(),
        'marker ids',
        ['a'],
      ),
    ],
  );

  blocTest<MapCubit, MapState>(
    'queries nearby with the app-wide radius',
    build: build,
    act: (c) => c.load(),
    verify: (_) => expect(repo.lastRadius, AppGeo.nearbyRadiusMeters),
  );

  blocTest<MapCubit, MapState>(
    'emits MapError when the nearby query fails',
    build: () {
      repo.nearbyError = const ApiException('network down');
      return build();
    },
    act: (c) => c.load(),
    expect: () => [
      isA<MapLoading>(),
      isA<MapError>().having((s) => s.message, 'message', 'network down'),
    ],
  );

  group('MapFilter', () {
    const marker = VehicleMarker(
      vehicleId: 'a',
      position: GeoPoint(21.0, 105.0),
      title: 'x',
      pricePerDay: 1,
      type: 'CAR',
    );

    test('empty filter matches everything', () {
      expect(const MapFilter().matches(marker), isTrue);
    });

    test('toggleType adds then removes a type', () {
      final added = const MapFilter().toggleType('CAR');
      expect(added.types, {'CAR'});
      expect(added.matches(marker), isTrue);
      expect(added.toggleType('CAR').types, isEmpty);
    });

    test('a filter on another type excludes the marker', () {
      expect(const MapFilter(types: {'MOTORBIKE'}).matches(marker), isFalse);
    });
  });

  blocTest<MapCubit, MapState>(
    'toggleType narrows the visible markers without refetching',
    build: () {
      repo.nearbyResult = [_vehicle('a', lat: 21.0, lng: 105.0)]; // CAR
      return build();
    },
    act: (c) async {
      await c.load();
      c.toggleType('MOTORBIKE'); // không khớp CAR → ẩn hết
    },
    expect: () => [
      isA<MapLoading>(),
      isA<MapLoaded>().having((s) => s.markers, 'markers', isNotEmpty),
      isA<MapLoaded>().having((s) => s.markers, 'filtered markers', isEmpty),
    ],
  );
}
