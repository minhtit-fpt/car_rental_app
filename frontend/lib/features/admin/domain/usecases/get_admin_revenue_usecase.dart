import 'package:frontend/features/admin/domain/entities/admin_revenue_point.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class GetAdminRevenueUseCase {
  const GetAdminRevenueUseCase(this._repository);

  final AdminRepository _repository;

  Future<List<AdminRevenuePoint>> call({int months = 6}) =>
      _repository.listRevenue(months: months);
}
