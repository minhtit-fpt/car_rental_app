import 'package:frontend/features/owner/domain/entities/owner_revenue.dart';

/// Ánh xạ JSON `OwnerRevenue` của backend → entity.
abstract final class OwnerRevenueModel {
  static OwnerRevenue fromJson(Map<String, dynamic> json) {
    final monthly = (json['monthly'] as List<dynamic>? ?? const [])
        .map((e) => e as Map<String, dynamic>)
        .map(
          (m) => RevenuePoint(
            month: m['month'] as String,
            total: (m['total'] as num).toDouble(),
          ),
        )
        .toList(growable: false);

    final transactions = (json['transactions'] as List<dynamic>? ?? const [])
        .map((e) => e as Map<String, dynamic>)
        .map(
          (t) => OwnerTransaction(
            id: t['id'] as String,
            amount: (t['amount'] as num).toDouble(),
            paidAt: t['paidAt'] == null
                ? null
                : DateTime.parse(t['paidAt'] as String),
            startTime: DateTime.parse(t['startTime'] as String),
            endTime: DateTime.parse(t['endTime'] as String),
            renterPhone: t['renterPhone'] as String,
            renterEmail: t['renterEmail'] as String?,
            vehicleTitle: t['vehicleTitle'] as String,
          ),
        )
        .toList(growable: false);

    return OwnerRevenue(
      monthRevenue: (json['monthRevenue'] as num).toDouble(),
      totalTrips: json['totalTrips'] as int? ?? 0,
      monthly: monthly,
      transactions: transactions,
    );
  }
}
