import 'package:frontend/features/loyalty/domain/entities/loyalty.dart';

/// Ánh xạ JSON `LoyaltySummary` của backend → entity.
abstract final class LoyaltyModel {
  static LoyaltyTier _tierFromJson(String? raw) => switch (raw) {
    'SILVER' => LoyaltyTier.silver,
    'GOLD' => LoyaltyTier.gold,
    'PLATINUM' => LoyaltyTier.platinum,
    _ => LoyaltyTier.bronze,
  };

  static LoyaltyEntry _entryFromJson(Map<String, dynamic> json) => LoyaltyEntry(
    id: json['id'] as String,
    points: json['points'] as int,
    action: json['action'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  static LoyaltySummary fromJson(Map<String, dynamic> json) => LoyaltySummary(
    totalPoints: json['totalPoints'] as int,
    tier: _tierFromJson(json['tier'] as String?),
    nextTier: json['nextTier'] == null
        ? null
        : _tierFromJson(json['nextTier'] as String),
    pointsToNextTier: json['pointsToNextTier'] as int,
    history: (json['history'] as List<dynamic>)
        .map((e) => _entryFromJson(e as Map<String, dynamic>))
        .toList(growable: false),
  );
}
