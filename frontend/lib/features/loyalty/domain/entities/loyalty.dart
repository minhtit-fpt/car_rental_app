/// Hạng thành viên — phản chiếu `LoyaltyTier` của backend.
enum LoyaltyTier { bronze, silver, gold, platinum }

extension LoyaltyTierLabel on LoyaltyTier {
  String get label => switch (this) {
    LoyaltyTier.bronze => 'Bronze',
    LoyaltyTier.silver => 'Silver',
    LoyaltyTier.gold => 'Gold',
    LoyaltyTier.platinum => 'Platinum',
  };
}

/// Một dòng lịch sử điểm (tích hoặc tiêu).
class LoyaltyEntry {
  const LoyaltyEntry({
    required this.id,
    required this.points,
    required this.action,
    required this.createdAt,
  });

  final String id;
  final int points;
  final String action;
  final DateTime createdAt;

  bool get isEarn => points >= 0;
}

/// Tổng quan điểm thưởng (`GET /api/loyalty`).
class LoyaltySummary {
  const LoyaltySummary({
    required this.totalPoints,
    required this.tier,
    required this.pointsToNextTier,
    required this.history,
    this.nextTier,
  });

  final int totalPoints;
  final LoyaltyTier tier;
  final LoyaltyTier? nextTier;
  final int pointsToNextTier;
  final List<LoyaltyEntry> history;
}
