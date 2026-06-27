import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/location/app_geo.dart';
import 'package:frontend/features/map/presentation/vehicle_marker.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

Vehicle _vehicle({String id = 'v1', double? latitude, double? longitude}) =>
    Vehicle(
      id: id,
      ownerId: 'o1',
      type: 'CAR',
      title: 'Toyota Vios',
      pricePerHour: 50000,
      isElectric: false,
      isAvailable: true,
      deliveryAvailable: false,
      latitude: latitude,
      longitude: longitude,
    );

void main() {
  group('vehicleMarkers', () {
    test('maps a vehicle with coordinates to a marker', () {
      final markers = vehicleMarkers([
        _vehicle(latitude: 21.03, longitude: 105.85),
      ]);

      expect(markers, hasLength(1));
      expect(markers.single.vehicleId, 'v1');
      expect(markers.single.position, const GeoPoint(21.03, 105.85));
      expect(markers.single.title, 'Toyota Vios');
      expect(markers.single.pricePerHour, 50000);
      expect(markers.single.type, 'CAR');
    });

    test('drops vehicles missing latitude or longitude', () {
      final markers = vehicleMarkers([
        _vehicle(id: 'a', latitude: 21.0, longitude: 105.0),
        _vehicle(id: 'b'), // no coords (list/detail vehicle)
        _vehicle(id: 'c', latitude: 10.0), // only lat
      ]);

      expect(markers.map((m) => m.vehicleId), ['a']);
    });

    test('returns empty list for empty input', () {
      expect(vehicleMarkers(const []), isEmpty);
    });
  });
}
