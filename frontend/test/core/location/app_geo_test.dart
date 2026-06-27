import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/location/app_geo.dart';

void main() {
  group('AppGeo.cityCenterOf', () {
    test('maps a known city to its centre', () {
      expect(AppGeo.cityCenterOf('Hà Nội'), AppGeo.cityCenters['ha noi']);
      expect(AppGeo.cityCenterOf('Đà Nẵng'), AppGeo.cityCenters['da nang']);
    });

    test('is case- and diacritic-insensitive', () {
      final a = AppGeo.cityCenterOf('HỒ CHÍ MINH');
      final b = AppGeo.cityCenterOf('ho chi minh');
      expect(a, b);
      expect(a, AppGeo.cityCenters['ho chi minh']);
    });

    test('collapses extra whitespace', () {
      expect(
        AppGeo.cityCenterOf('  da   nang  '),
        AppGeo.cityCenters['da nang'],
      );
    });

    test('falls back to default centre for null/unknown city', () {
      expect(AppGeo.cityCenterOf(null), AppGeo.defaultCenter);
      expect(AppGeo.cityCenterOf(''), AppGeo.defaultCenter);
      expect(AppGeo.cityCenterOf('Atlantis'), AppGeo.defaultCenter);
    });
  });

  group('GeoPoint', () {
    test('value equality', () {
      expect(const GeoPoint(1, 2), const GeoPoint(1, 2));
      expect(const GeoPoint(1, 2), isNot(const GeoPoint(2, 1)));
    });
  });
}
