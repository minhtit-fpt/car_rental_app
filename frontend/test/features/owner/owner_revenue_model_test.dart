import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/owner/data/models/owner_revenue_model.dart';

void main() {
  group('OwnerRevenueModel.fromJson per-vehicle stats', () {
    Map<String, dynamic> baseJson() => {
      'monthRevenue': 100,
      'totalTrips': 2,
      'monthly': const [],
      'transactions': const [],
    };

    test('parses vehicle stats and keeps null rating', () {
      final revenue = OwnerRevenueModel.fromJson({
        ...baseJson(),
        'vehicles': [
          {
            'vehicleId': 'v-1',
            'title': 'Car A',
            'earnings': 500,
            'trips': 3,
            'avgRating': 4.5,
          },
          {
            'vehicleId': 'v-2',
            'title': 'Car B',
            'earnings': 0,
            'trips': 0,
            'avgRating': null,
          },
        ],
      });

      expect(revenue.vehicles, hasLength(2));
      expect(revenue.vehicles.first.avgRating, 4.5);
      expect(revenue.vehicles.first.earnings, 500);
      expect(revenue.vehicles[1].avgRating, isNull);
    });

    test('defaults to empty list when vehicles missing', () {
      final revenue = OwnerRevenueModel.fromJson(baseJson());
      expect(revenue.vehicles, isEmpty);
    });
  });
}
