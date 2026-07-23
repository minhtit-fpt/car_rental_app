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

  /// Dữ liệu điều hướng kèm theo (vd `bookingId`, `conversationId`, `role`).
  final Map<String, dynamic>? payload;

  bool get isRead => readAt != null;

  /// Route đích khi mở thông báo (in-app tap hoặc tap popup khay OS).
  /// `null` nếu không có đích cụ thể.
  String? get targetRoute {
    switch (type) {
      case NotificationType.chat:
        final conversationId = payload?['conversationId'];
        return conversationId is String ? '/chat/$conversationId' : null;
      case NotificationType.kyc:
        return '/kyc/status';
      case NotificationType.booking:
      case NotificationType.payment:
        final bookingId = payload?['bookingId'];
        if (payload?['role'] == 'owner') {
          return bookingId is String
              ? '/owner/booking-request/$bookingId'
              : '/owner/booking-request';
        }
        return bookingId is String ? '/trips/detail/$bookingId' : '/trips';
      case NotificationType.promotion:
      case NotificationType.system:
        return null;
    }
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
