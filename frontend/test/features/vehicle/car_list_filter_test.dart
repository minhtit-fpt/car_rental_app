import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/screens/car_list_screen.dart';

Vehicle _vehicle({
  required String id,
  double pricePerDay = 50000,
  bool isElectric = false,
  double? rating,
  int? reviewCount,
}) => Vehicle(
  id: id,
  ownerId: 'owner',
  type: 'CAR',
  title: 'Car $id',
  pricePerDay: pricePerDay,
  isElectric: isElectric,
  isAvailable: true,
  deliveryAvailable: false,
  rating: rating,
  reviewCount: reviewCount,
);

void main() {
  // pricePerDayK = pricePerDay / 1000 (đơn vị K VNĐ).
  final cheap = _vehicle(id: 'cheap', pricePerDay: 40000); // 40K
  final mid = _vehicle(id: 'mid', pricePerDay: 50000); // 50K
  final pricey = _vehicle(id: 'pricey', pricePerDay: 80000); // 80K
  final electric = _vehicle(id: 'ev', pricePerDay: 50000, isElectric: true);
  final lowRated = _vehicle(id: 'low', rating: 3.5, reviewCount: 4);
  final highRated = _vehicle(id: 'high', rating: 4.6, reviewCount: 10);
  final unrated = _vehicle(id: 'unrated'); // rating == null

  group('applyVehicleFilters', () {
    test('returns all vehicles when no filters are set', () {
      final all = [cheap, mid, pricey];
      expect(applyVehicleFilters(all), all);
    });

    test('keeps only electric vehicles when electricOnly is true', () {
      final result = applyVehicleFilters([cheap, electric], electricOnly: true);
      expect(result, [electric]);
    });

    test('removes vehicles whose daily price exceeds maxPrice', () {
      final result = applyVehicleFilters([cheap, mid, pricey], maxPrice: 60);
      expect(result, [cheap, mid]);
    });

    test('keeps vehicles priced exactly at maxPrice (inclusive)', () {
      final result = applyVehicleFilters([mid], maxPrice: 50);
      expect(result, [mid]);
    });

    test('removes rated vehicles below minRating', () {
      final result = applyVehicleFilters([lowRated, highRated], minRating: 4.0);
      expect(result, [highRated]);
    });

    test('keeps unrated vehicles when minRating is set', () {
      // Backend chưa trả rating cho nhiều xe → không loại chúng khỏi kết quả.
      final result = applyVehicleFilters([unrated, highRated], minRating: 4.0);
      expect(result, [unrated, highRated]);
    });

    test('combines electric, price, and rating filters', () {
      final evCheapHigh = _vehicle(
        id: 'evCheapHigh',
        pricePerDay: 40000,
        isElectric: true,
        rating: 4.8,
        reviewCount: 5,
      );
      final evPricey = _vehicle(
        id: 'evPricey',
        pricePerDay: 90000,
        isElectric: true,
        rating: 4.8,
        reviewCount: 5,
      );
      final result = applyVehicleFilters(
        [cheap, evCheapHigh, evPricey, electric],
        electricOnly: true,
        maxPrice: 60,
        minRating: 4.0,
      );
      // evCheapHigh: electric ✓, 40K ≤ 60 ✓, 4.8 ≥ 4.0 ✓
      // evPricey: electric ✓, 90K > 60 ✗ → loại
      // electric (id 'ev'): electric ✓, 50K ✓, unrated → pass ✓
      expect(result, [evCheapHigh, electric]);
    });
  });
}
