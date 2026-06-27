/// Format giá thuê/ngày. `Vehicle.pricePerDay` lưu theo đơn vị nghìn VND (K):
/// vd 890 → "890K", 1200 → "1.2M". Trích ra dùng chung cho car card, share,
/// và marker bản đồ (trước đây mỗi nơi tự copy một bản).
String formatPricePerDayK(double kAmount, {bool withCurrency = false}) {
  final suffix = withCurrency ? ' VNĐ' : '';
  if (kAmount >= 1000) {
    final m = kAmount / 1000;
    if (m == m.truncateToDouble()) return '${m.truncate()}M$suffix';
    return '${m.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '')}M$suffix';
  }
  return '${kAmount.toInt()}K$suffix';
}
