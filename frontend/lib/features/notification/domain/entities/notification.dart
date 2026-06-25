/// Loại thông báo — phản chiếu enum `NotificationType` của backend.
enum NotificationType { booking, payment, kyc, chat, promotion, system }

/// Một thông báo của người dùng — phản chiếu `PublicNotification` của backend.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.createdAt,
    this.body,
    this.readAt,
    this.payload,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String? body;
  final DateTime createdAt;
  final DateTime? readAt;

  /// Ngữ cảnh kèm theo (vd `{ "bookingId": "..." }`) — dùng để điều hướng.
  final Map<String, dynamic>? payload;

  bool get isRead => readAt != null;

  /// Mã chuyến đặt liên quan, nếu có.
  String? get bookingId {
    final value = payload?['bookingId'];
    return value is String ? value : null;
  }
}

/// Danh sách thông báo + số chưa đọc (`GET /api/notifications`).
class NotificationList {
  const NotificationList({
    required this.items,
    required this.total,
    required this.unreadCount,
    required this.page,
    required this.limit,
  });

  final List<AppNotification> items;
  final int total;
  final int unreadCount;
  final int page;
  final int limit;
}
