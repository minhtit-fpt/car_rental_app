import 'package:frontend/features/notification/domain/repositories/notification_repository.dart';

/// Đánh dấu đã đọc tất cả thông báo (`POST /api/notifications/read-all`).
class MarkAllNotificationsReadUseCase {
  const MarkAllNotificationsReadUseCase(this._repository);

  final NotificationRepository _repository;

  Future<void> call() => _repository.markAllRead();
}
