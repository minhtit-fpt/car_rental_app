import 'package:frontend/features/admin/domain/entities/admin_metrics.dart';

sealed class AdminMetricsState {
  const AdminMetricsState();
}

final class AdminMetricsLoading extends AdminMetricsState {
  const AdminMetricsLoading();
}

final class AdminMetricsLoaded extends AdminMetricsState {
  const AdminMetricsLoaded(this.metrics);
  final AdminMetrics metrics;
}

final class AdminMetricsError extends AdminMetricsState {
  const AdminMetricsError(this.message);
  final String message;
}
