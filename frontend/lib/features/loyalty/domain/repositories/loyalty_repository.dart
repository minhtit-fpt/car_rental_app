import 'package:frontend/features/loyalty/domain/entities/loyalty.dart';

/// Hợp đồng domain cho điểm thưởng (`/api/loyalty`).
abstract interface class LoyaltyRepository {
  /// `GET /api/loyalty` — tổng điểm + hạng + lịch sử.
  Future<LoyaltySummary> getSummary({int page, int limit});
}
