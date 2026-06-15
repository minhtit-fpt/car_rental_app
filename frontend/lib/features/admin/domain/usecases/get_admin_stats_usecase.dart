import 'package:frontend/features/admin/domain/entities/admin_stats.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class GetAdminStatsUseCase {
  const GetAdminStatsUseCase(this._repository);

  final AdminRepository _repository;

  Future<AdminStats> call() => _repository.getStats();
}
