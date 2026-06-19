import 'package:frontend/features/owner/domain/entities/owner_revenue.dart';
import 'package:frontend/features/owner/domain/repositories/owner_repository.dart';

/// Tổng quan doanh thu chủ xe (`GET /api/owner/revenue`).
class GetOwnerRevenueUseCase {
  const GetOwnerRevenueUseCase(this._repository);

  final OwnerRepository _repository;

  Future<OwnerRevenue> call({int months = 6}) =>
      _repository.getRevenue(months: months);
}
