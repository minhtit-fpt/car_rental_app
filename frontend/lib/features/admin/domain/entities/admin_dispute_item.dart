/// Một tranh chấp trong hàng đợi quản trị (`/api/admin/disputes`).
class AdminDisputeItem {
  const AdminDisputeItem({
    required this.id,
    required this.bookingId,
    required this.title,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final String title;
  final String priority; // HIGH | MEDIUM | LOW
  final String status; // OPEN | RESOLVED | REJECTED
  final DateTime createdAt;

  /// Mã booking rút gọn để hiển thị (vd 'BK #a1b2c3d4').
  String get bookingRef {
    final short = bookingId.length >= 8 ? bookingId.substring(0, 8) : bookingId;
    return 'BK #$short';
  }
}
