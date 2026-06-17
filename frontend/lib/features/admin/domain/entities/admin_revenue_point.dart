/// Một cột doanh thu theo tháng (`/api/admin/revenue`).
class AdminRevenuePoint {
  const AdminRevenuePoint({required this.month, required this.total});

  /// Khoá tháng dạng 'YYYY-MM'.
  final String month;

  /// Tổng doanh thu PAID trong tháng (VND).
  final double total;

  /// Nhãn trục 'Th.X' suy ra từ phần tháng.
  String get label {
    final parts = month.split('-');
    final m = parts.length > 1 ? int.tryParse(parts[1]) : null;
    return m != null ? 'Th.$m' : month;
  }

  /// Doanh thu quy theo triệu VND (M) cho trục biểu đồ.
  double get totalInMillions => total / 1000000;
}
