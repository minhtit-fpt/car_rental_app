import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/utils/price_format.dart';

void main() {
  group('formatPricePerDayK', () {
    test('formats sub-million amounts as K', () {
      expect(formatPricePerDayK(890), '890K');
      expect(formatPricePerDayK(50), '50K');
    });

    test('formats whole millions without decimals', () {
      expect(formatPricePerDayK(1000), '1M');
      expect(formatPricePerDayK(2000), '2M');
    });

    test('trims trailing zeros on fractional millions', () {
      expect(formatPricePerDayK(1200), '1.2M');
      expect(formatPricePerDayK(1250), '1.25M');
    });

    test('appends currency when requested', () {
      expect(formatPricePerDayK(890, withCurrency: true), '890K VNĐ');
      expect(formatPricePerDayK(1200, withCurrency: true), '1.2M VNĐ');
    });
  });
}
