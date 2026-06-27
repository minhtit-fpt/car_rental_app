/// Số liệu tổng quan của ADMIN (tương ứng `/api/admin/stats`).
class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.activeBookings,
    required this.pendingKyc,
    required this.monthlyRevenue,
  });

  final int totalUsers;
  final int activeBookings;
  final int pendingKyc;

  /// Doanh thu tháng hiện tại (VNĐ).
  final double monthlyRevenue;
}
