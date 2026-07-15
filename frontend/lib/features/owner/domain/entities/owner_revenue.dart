/// Một điểm doanh thu theo tháng (`YYYY-MM`).
class RevenuePoint {
  const RevenuePoint({required this.month, required this.total});

  final String month;
  final double total;
}

/// Một giao dịch (thanh toán PAID) trong báo cáo doanh thu owner.
class OwnerTransaction {
  const OwnerTransaction({
    required this.id,
    required this.amount,
    required this.paidAt,
    required this.startTime,
    required this.endTime,
    required this.renterPhone,
    required this.renterEmail,
    required this.vehicleTitle,
  });

  final String id;
  final double amount;
  final DateTime? paidAt;
  final DateTime startTime;
  final DateTime endTime;
  final String renterPhone;
  final String? renterEmail;
  final String vehicleTitle;

  String get renterDisplayName => renterEmail ?? renterPhone;
}

/// Thống kê theo từng xe của owner — phản chiếu `OwnerVehicleStat` của backend.
class OwnerVehicleStat {
  const OwnerVehicleStat({
    required this.vehicleId,
    required this.title,
    required this.earnings,
    required this.trips,
    required this.avgRating,
  });

  final String vehicleId;
  final String title;
  final double earnings;
  final int trips;
  final double? avgRating;
}

/// Tổng quan doanh thu chủ xe — phản chiếu `OwnerRevenue` của backend.
class OwnerRevenue {
  const OwnerRevenue({
    required this.monthRevenue,
    required this.totalTrips,
    required this.monthly,
    required this.transactions,
    required this.vehicles,
  });

  final double monthRevenue;
  final int totalTrips;
  final List<RevenuePoint> monthly;
  final List<OwnerTransaction> transactions;
  final List<OwnerVehicleStat> vehicles;
}
