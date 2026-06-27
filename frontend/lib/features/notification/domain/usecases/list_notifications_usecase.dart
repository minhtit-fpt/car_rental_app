import 'package:frontend/features/notification/domain/entities/notification.dart';
import 'package:frontend/features/notification/domain/repositories/notification_repository.dart';

/// Lấy danh sách thông báo + số chưa đọc (`GET /api/notifications`).
class ListNotificationsUseCase {
  const ListNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  Future<NotificationList> call({int page = 1, int limit = 20}) =>
      _repository.list(page: page, limit: limit);
}
