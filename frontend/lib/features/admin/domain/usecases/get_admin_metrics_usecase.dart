import 'package:frontend/features/admin/domain/entities/admin_metrics.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class GetAdminMetricsUseCase {
  const GetAdminMetricsUseCase(this._repository);

  final AdminRepository _repository;

  Future<AdminMetrics> call() => _repository.getMetrics();
}
