import 'package:frontend/features/admin/domain/entities/admin_revenue_point.dart';

sealed class AdminRevenueState {
  const AdminRevenueState();
}

final class AdminRevenueLoading extends AdminRevenueState {
  const AdminRevenueLoading();
}

final class AdminRevenueLoaded extends AdminRevenueState {
  const AdminRevenueLoaded(this.points);
  final List<AdminRevenuePoint> points;
}

final class AdminRevenueError extends AdminRevenueState {
  const AdminRevenueError(this.message);
  final String message;
}
