import 'package:frontend/features/owner/domain/entities/owner_revenue.dart';

sealed class OwnerRevenueState {
  const OwnerRevenueState();
}

final class OwnerRevenueLoading extends OwnerRevenueState {
  const OwnerRevenueLoading();
}

final class OwnerRevenueLoaded extends OwnerRevenueState {
  const OwnerRevenueLoaded(this.revenue);
  final OwnerRevenue revenue;
}

final class OwnerRevenueError extends OwnerRevenueState {
  const OwnerRevenueError(this.message);
  final String message;
}
