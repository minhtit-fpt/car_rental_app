import 'package:frontend/features/vehicle/domain/entities/price_quote.dart';

/// Parse envelope `data` của `GET /api/vehicles/:id/price-quote`.
class PriceQuoteModel extends PriceQuote {
  const PriceQuoteModel({
    required super.basePricePerHour,
    required super.hours,
    required super.basePrice,
    required super.factors,
    required super.finalPrice,
    required super.currency,
  });

  factory PriceQuoteModel.fromJson(Map<String, dynamic> json) {
    final rawFactors = (json['factors'] as List<dynamic>? ?? const []);
    return PriceQuoteModel(
      basePricePerHour: (json['basePricePerHour'] as num).toDouble(),
      hours: (json['hours'] as num).toInt(),
      basePrice: (json['basePrice'] as num).toDouble(),
      finalPrice: (json['finalPrice'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'VND',
      factors: rawFactors
          .map((e) => _factorFromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  static PriceFactor _factorFromJson(Map<String, dynamic> json) => PriceFactor(
    code: json['code'] as String,
    label: json['label'] as String,
    multiplier: (json['multiplier'] as num).toDouble(),
  );
}
