import 'package:frontend/features/notification/domain/entities/notification.dart';

/// Hợp đồng domain cho thông báo (`/api/notifications`).
abstract interface class NotificationRepository {
  /// `GET /api/notifications` — danh sách thông báo + số chưa đọc.
  Future<NotificationList> list({int page, int limit});

  /// `POST /api/notifications/:id/read` — đánh dấu đã đọc, trả số chưa đọc còn lại.
  Future<int> markRead(String id);

  /// `POST /api/notifications/read-all` — đánh dấu đã đọc tất cả.
  Future<void> markAllRead();
}
