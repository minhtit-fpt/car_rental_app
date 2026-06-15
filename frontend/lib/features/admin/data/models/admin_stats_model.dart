import 'package:frontend/features/admin/domain/entities/admin_stats.dart';

abstract final class AdminStatsModel {
  static AdminStats fromJson(Map<String, dynamic> json) => AdminStats(
        totalUsers: (json['totalUsers'] as num).toInt(),
        activeBookings: (json['activeBookings'] as num).toInt(),
        pendingKyc: (json['pendingKyc'] as num).toInt(),
        monthlyRevenue: (json['monthlyRevenue'] as num).toDouble(),
      );
}
