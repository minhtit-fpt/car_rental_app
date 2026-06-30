/// Một đơn trong danh sách quản lý của ADMIN (`/api/admin/bookings`).
class AdminBookingItem {
  const AdminBookingItem({
    required this.id,
    required this.vehicleTitle,
    required this.status,
    required this.totalPrice,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.paymentStatus,
  });

  final String id;
  final String vehicleTitle;
  final String status; // PENDING_PAYMENT | CONFIRMED | IN_PROGRESS | COMPLETED | CANCELLED
  final double totalPrice;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  final String? paymentStatus; // PENDING | PAID | FAILED | REFUNDED | null
}
