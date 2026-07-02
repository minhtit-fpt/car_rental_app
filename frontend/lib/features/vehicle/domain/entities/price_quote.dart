/// Báo giá động cho một lượt thuê — khớp `PriceQuote` của backend
/// (`GET /api/vehicles/:id/price-quote`). Mỗi [PriceFactor] là một yếu tố surge
/// CÓ GIẢI THÍCH để hiển thị cho người dùng (cuối tuần, lễ, giảm
/// giá thuê dài, cung/cầu).
class PriceQuote {
  const PriceQuote({
    required this.basePricePerDay,
    required this.days,
    required this.basePrice,
    required this.factors,
    required this.finalPrice,
    required this.currency,
  });

  /// Giá gốc/ngày (VND) — chủ xe đặt trong app.
  final double basePricePerDay;
  final int days;

  /// basePricePerDay × days, TRƯỚC khi áp các yếu tố surge.
  final double basePrice;

  /// Các yếu tố đang áp dụng (rỗng nếu giá đúng bằng giá gốc).
  final List<PriceFactor> factors;

  /// Giá cuối sau khi nhân tất cả bội số, đã làm tròn VND.
  final double finalPrice;
  final String currency;

  /// Có điều chỉnh so với giá gốc hay không (để UI hiện/ẩn phần breakdown).
  bool get hasAdjustments => factors.isNotEmpty;
}

class PriceFactor {
  const PriceFactor({
    required this.code,
    required this.label,
    required this.multiplier,
  });

  /// Mã yếu tố: PEAK_HOUR | WEEKEND | HOLIDAY | DURATION_DISCOUNT | DEMAND.
  final String code;

  /// Nhãn tiếng Việt do backend cấp (vd "Giờ cao điểm") — hiển thị trực tiếp.
  final String label;

  /// Bội số: >1 phụ thu, <1 giảm giá.
  final double multiplier;

  /// Chênh lệch phần trăm có dấu (vd +15, -15) để hiển thị gọn.
  int get percentDelta => ((multiplier - 1) * 100).round();

  bool get isDiscount => multiplier < 1;
}
