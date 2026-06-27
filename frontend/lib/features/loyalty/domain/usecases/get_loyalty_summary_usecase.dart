import 'package:frontend/features/loyalty/domain/entities/loyalty.dart';
import 'package:frontend/features/loyalty/domain/repositories/loyalty_repository.dart';

/// Lấy tổng quan điểm thưởng (`GET /api/loyalty`).
class GetLoyaltySummaryUseCase {
  const GetLoyaltySummaryUseCase(this._repository);

  final LoyaltyRepository _repository;

  Future<LoyaltySummary> call({int page = 1, int limit = 20}) =>
      _repository.getSummary(page: page, limit: limit);
}
