import 'package:frontend/features/admin/domain/entities/admin_stats.dart';

/// State của số liệu tổng quan admin.
sealed class AdminStatsState {
  const AdminStatsState();
}

final class AdminStatsLoading extends AdminStatsState {
  const AdminStatsLoading();
}

final class AdminStatsLoaded extends AdminStatsState {
  const AdminStatsLoaded(this.stats);
  final AdminStats stats;
}

final class AdminStatsError extends AdminStatsState {
  const AdminStatsError(this.message);
  final String message;
}
