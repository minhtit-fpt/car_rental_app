import 'package:frontend/features/admin/domain/entities/admin_revenue_point.dart';

abstract final class AdminRevenuePointModel {
  static AdminRevenuePoint fromJson(Map<String, dynamic> json) =>
      AdminRevenuePoint(
        month: json['month'] as String,
        total: (json['total'] as num).toDouble(),
      );
}
