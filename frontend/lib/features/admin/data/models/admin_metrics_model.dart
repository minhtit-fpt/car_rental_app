import 'package:frontend/features/admin/domain/entities/admin_metrics.dart';

abstract final class AdminMetricsModel {
  static AdminMetrics fromJson(Map<String, dynamic> json) {
    final kpi = json['kpi'] as Map<String, dynamic>;
    return AdminMetrics(
      kpi: AdminKpi(
        totalUsers: _int(kpi['totalUsers']),
        totalVehicles: _int(kpi['totalVehicles']),
        availableVehicles: _int(kpi['availableVehicles']),
        electricVehicles: _int(kpi['electricVehicles']),
        totalBookings: _int(kpi['totalBookings']),
        completionRate: _double(kpi['completionRate']),
        cancellationRate: _double(kpi['cancellationRate']),
        avgRating: _double(kpi['avgRating']),
      ),
      bookingsByStatus: _list(
        json['bookingsByStatus'],
        (e) => BookingStatusMetric(
          status: e['status'] as String,
          count: _int(e['count']),
        ),
      ),
      paymentsByMethod: _list(
        json['paymentsByMethod'],
        (e) => PaymentMethodMetric(
          method: e['method'] as String,
          total: _double(e['total']),
        ),
      ),
      vehiclesByType: _list(
        json['vehiclesByType'],
        (e) => VehicleTypeMetric(
          type: e['type'] as String,
          count: _int(e['count']),
          electric: _int(e['electric']),
        ),
      ),
      topVehicles: _list(
        json['topVehicles'],
        (e) => TopVehicle(
          id: e['id'] as String,
          title: e['title'] as String,
          revenue: _double(e['revenue']),
          trips: _int(e['trips']),
        ),
      ),
      recentBookings: _list(
        json['recentBookings'],
        (e) => RecentBooking(
          id: e['id'] as String,
          vehicleTitle: e['vehicleTitle'] as String,
          status: e['status'] as String,
          totalPrice: _double(e['totalPrice']),
          createdAt: DateTime.parse(e['createdAt'] as String),
        ),
      ),
    );
  }

  static List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) map) =>
      (raw as List<dynamic>)
          .map((e) => map(e as Map<String, dynamic>))
          .toList(growable: false);

  static int _int(dynamic v) => (v as num).toInt();
  static double _double(dynamic v) => (v as num).toDouble();
}
