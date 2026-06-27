import 'package:frontend/features/notification/domain/repositories/notification_repository.dart';

/// Đánh dấu một thông báo đã đọc; trả số chưa đọc còn lại
/// (`POST /api/notifications/:id/read`).
class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase(this._repository);

  final NotificationRepository _repository;

  Future<int> call(String id) => _repository.markRead(id);
}
