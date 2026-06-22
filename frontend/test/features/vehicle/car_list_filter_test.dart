import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/screens/car_list_screen.dart';

Vehicle _vehicle({
  required String id,
  double pricePerHour = 50000,
  bool isElectric = false,
  double? rating,
  int? reviewCount,
}) => Vehicle(
  id: id,
  ownerId: 'owner',
  type: 'CAR',
  title: 'Car $id',
  pricePerHour: pricePerHour,
  isElectric: isElectric,
  isAvailable: true,
  deliveryAvailable: false,
  rating: rating,
  reviewCount: reviewCount,
);

void main() {
  // pricePerDay = pricePerHour * 24 / 1000 (đơn vị K VNĐ).
  final cheap = _vehicle(id: 'cheap', pricePerHour: 40000); // 960K
  final mid = _vehicle(id: 'mid', pricePerHour: 50000); // 1200K
  final pricey = _vehicle(id: 'pricey', pricePerHour: 80000); // 1920K
  final electric = _vehicle(id: 'ev', pricePerHour: 50000, isElectric: true);
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
      final result = applyVehicleFilters([cheap, mid, pricey], maxPrice: 1500);
      expect(result, [cheap, mid]);
    });

    test('keeps vehicles priced exactly at maxPrice (inclusive)', () {
      final result = applyVehicleFilters([mid], maxPrice: 1200);
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
        pricePerHour: 40000,
        isElectric: true,
        rating: 4.8,
        reviewCount: 5,
      );
      final evPricey = _vehicle(
        id: 'evPricey',
        pricePerHour: 90000,
        isElectric: true,
        rating: 4.8,
        reviewCount: 5,
      );
      final result = applyVehicleFilters(
        [cheap, evCheapHigh, evPricey, electric],
        electricOnly: true,
        maxPrice: 1500,
        minRating: 4.0,
      );
      // evCheapHigh: electric ✓, 960K ≤ 1500 ✓, 4.8 ≥ 4.0 ✓
      // electric (id 'ev'): electric ✓, 1200K ✓, unrated → pass ✓
      expect(result, [evCheapHigh, electric]);
    });
  });
}
