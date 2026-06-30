/// Tổng hợp số liệu dashboard quản trị (`GET /api/admin/metrics`).
class AdminMetrics {
  const AdminMetrics({
    required this.kpi,
    required this.bookingsByStatus,
    required this.paymentsByMethod,
    required this.vehiclesByType,
    required this.topVehicles,
    required this.recentBookings,
  });

  final AdminKpi kpi;
  final List<BookingStatusMetric> bookingsByStatus;
  final List<PaymentMethodMetric> paymentsByMethod;
  final List<VehicleTypeMetric> vehiclesByType;
  final List<TopVehicle> topVehicles;
  final List<RecentBooking> recentBookings;
}

class AdminKpi {
  const AdminKpi({
    required this.totalUsers,
    required this.totalVehicles,
    required this.availableVehicles,
    required this.electricVehicles,
    required this.totalBookings,
    required this.completionRate,
    required this.cancellationRate,
    required this.avgRating,
  });

  final int totalUsers;
  final int totalVehicles;
  final int availableVehicles;
  final int electricVehicles;
  final int totalBookings;
  final double completionRate; // 0..1
  final double cancellationRate; // 0..1
  final double avgRating;
}

class BookingStatusMetric {
  const BookingStatusMetric({required this.status, required this.count});
  final String status;
  final int count;
}

class PaymentMethodMetric {
  const PaymentMethodMetric({required this.method, required this.total});
  final String method;
  final double total;
}

class VehicleTypeMetric {
  const VehicleTypeMetric({
    required this.type,
    required this.count,
    required this.electric,
  });
  final String type;
  final int count;
  final int electric;
}

class TopVehicle {
  const TopVehicle({
    required this.id,
    required this.title,
    required this.revenue,
    required this.trips,
  });
  final String id;
  final String title;
  final double revenue;
  final int trips;
}

class RecentBooking {
  const RecentBooking({
    required this.id,
    required this.vehicleTitle,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
  });
  final String id;
  final String vehicleTitle;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
}
