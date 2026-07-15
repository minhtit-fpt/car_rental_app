import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/utils/share_helper.dart';

/// Một xe mẫu tối thiểu cho test payload chia sẻ.
Vehicle _vehicle({
  String id = 'veh-1',
  String title = 'Toyota Vios',
  double pricePerDay = 50000, // → pricePerDayK = 50000/1000 = 50 (K)
}) => Vehicle(
  id: id,
  ownerId: 'owner-1',
  type: 'CAR',
  title: title,
  pricePerDay: pricePerDay,
  isElectric: false,
  isAvailable: true,
  deliveryAvailable: false,
);

void main() {
  group('vehicleShareLink', () {
    test('builds a /vehicles/:id deep link from the web base url', () {
      final link = vehicleShareLink('abc123');
      expect(link, endsWith('/vehicles/abc123'));
      expect(link, startsWith('http'));
    });
  });

  group('buildVehicleShareText', () {
    test('includes title, formatted price and link (English)', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      final text = buildVehicleShareText(l10n, _vehicle());

      expect(text, contains('Toyota Vios'));
      expect(text, contains('50K')); // 50000đ/ngày → 50K
      expect(text, contains('/vehicles/veh-1'));
    });

    test('formats sub-1M prices in K (Vietnamese)', () {
      final l10n = lookupAppLocalizations(const Locale('vi'));
      // 30000đ/ngày → 30000/1000 = 30 (K)
      final text = buildVehicleShareText(
        l10n,
        _vehicle(title: 'Honda Wave', pricePerDay: 30000),
      );

      expect(text, contains('Honda Wave'));
      expect(text, contains('30K'));
      expect(text, contains('/vehicles/veh-1'));
    });
  });
}
