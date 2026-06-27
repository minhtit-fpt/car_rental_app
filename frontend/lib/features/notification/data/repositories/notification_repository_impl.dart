import 'package:frontend/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:frontend/features/notification/data/models/notification_model.dart';
import 'package:frontend/features/notification/domain/entities/notification.dart';
import 'package:frontend/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._remote);

  final NotificationRemoteDataSource _remote;

  @override
  Future<NotificationList> list({int page = 1, int limit = 20}) async =>
      NotificationModel.listFromJson(
        await _remote.list(page: page, limit: limit),
      );

  @override
  Future<int> markRead(String id) async {
    final data = await _remote.markRead(id);
    return data['unreadCount'] as int;
  }

  @override
  Future<void> markAllRead() => _remote.markAllRead();
}
