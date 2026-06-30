import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/data/models/admin_metrics_model.dart';

void main() {
  test('AdminMetricsModel.fromJson parse kpi + các nhóm aggregation', () {
    final m = AdminMetricsModel.fromJson({
      'kpi': {
        'totalUsers': 100,
        'totalVehicles': 9,
        'availableVehicles': 7,
        'electricVehicles': 3,
        'totalBookings': 10,
        'completionRate': 0.5,
        'cancellationRate': 0.2,
        'avgRating': 4, // int → phải ép thành double
      },
      'bookingsByStatus': [
        {'status': 'COMPLETED', 'count': 5},
      ],
      'paymentsByMethod': [
        {'method': 'VNPAY', 'total': 1500000},
      ],
      'vehiclesByType': [
        {'type': 'CAR', 'count': 7, 'electric': 3},
      ],
      'topVehicles': [
        {'id': 'v1', 'title': 'Tesla', 'revenue': 2000000, 'trips': 4},
      ],
      'recentBookings': [
        {
          'id': 'b1',
          'vehicleTitle': 'Tesla',
          'status': 'COMPLETED',
          'totalPrice': 500000,
          'createdAt': '2026-06-01T10:00:00.000Z',
        },
      ],
    });

    expect(m.kpi.avgRating, 4.0);
    expect(m.kpi.completionRate, 0.5);
    expect(m.bookingsByStatus.single.count, 5);
    expect(m.paymentsByMethod.single.total, 1500000.0);
    expect(m.vehiclesByType.single.electric, 3);
    expect(m.topVehicles.single.title, 'Tesla');
    expect(m.recentBookings.single.createdAt.year, 2026);
  });
}
