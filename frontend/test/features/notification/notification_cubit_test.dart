import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/notifications/local_notification_service.dart';
import 'package:frontend/features/notification/domain/entities/notification.dart';
import 'package:frontend/features/notification/domain/repositories/notification_repository.dart';
import 'package:frontend/features/notification/domain/usecases/list_notifications_usecase.dart';
import 'package:frontend/features/notification/domain/usecases/mark_all_read_usecase.dart';
import 'package:frontend/features/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:frontend/features/notification/presentation/cubit/notification_cubit.dart';

AppNotification _notif(String id, {bool read = false}) => AppNotification(
  id: id,
  type: NotificationType.payment,
  title: 'Thông báo $id',
  body: 'Nội dung',
  createdAt: DateTime.utc(2026, 1, 1),
  readAt: read ? DateTime.utc(2026, 1, 1) : null,
);

NotificationList _list(List<AppNotification> items) => NotificationList(
  items: items,
  total: items.length,
  unreadCount: items.where((n) => !n.isRead).length,
  page: 1,
  limit: 20,
);

/// Fake repo trả về `listResult` (đổi được giữa các lần gọi để mô phỏng poll).
class _FakeNotificationRepository implements NotificationRepository {
  NotificationList listResult = _list(const []);

  @override
  Future<NotificationList> list({int page = 1, int limit = 20}) async =>
      listResult;

  @override
  Future<int> markRead(String id) async => 0;

  @override
  Future<void> markAllRead() async {}
}

/// Fake service ghi lại các thông báo đã được "popup".
class _FakeLocalNotificationService extends LocalNotificationService {
  final List<String> shownIds = <String>[];

  @override
  Future<void> init({void Function(String? payload)? onSelect}) async {}

  @override
  Future<void> show(AppNotification notif) async => shownIds.add(notif.id);
}

NotificationCubit _build(
  _FakeNotificationRepository repo,
  _FakeLocalNotificationService local,
) => NotificationCubit(
  listNotifications: ListNotificationsUseCase(repo),
  markRead: MarkNotificationReadUseCase(repo),
  markAllRead: MarkAllNotificationsReadUseCase(repo),
  localNotifications: local,
);

void main() {
  group('NotificationCubit', () {
    late _FakeNotificationRepository repo;
    late _FakeLocalNotificationService local;

    setUp(() {
      repo = _FakeNotificationRepository();
      local = _FakeLocalNotificationService();
    });

    test('load emits loaded and never pops up (user is viewing)', () async {
      repo.listResult = _list([_notif('a'), _notif('b')]);
      final cubit = _build(repo, local);

      await cubit.load();

      expect(cubit.state, isA<NotificationLoaded>());
      expect(local.shownIds, isEmpty);
      await cubit.close();
    });

    test('first poll only sets a baseline — no popup for existing unread',
        () async {
      repo.listResult = _list([_notif('a'), _notif('b')]);
      final cubit = _build(repo, local);

      await cubit.refreshNow(); // baseline
      await cubit.refreshNow(); // nothing new since

      expect(local.shownIds, isEmpty);
      await cubit.close();
    });

    test('pops up only for newly arrived unread notifications', () async {
      repo.listResult = _list([_notif('a')]);
      final cubit = _build(repo, local);

      await cubit.refreshNow(); // baseline sees {a}
      repo.listResult = _list([_notif('c'), _notif('a')]); // c is new
      await cubit.refreshNow();

      expect(local.shownIds, ['c']);
      await cubit.close();
    });

    test('does not pop up for already-read new notifications', () async {
      repo.listResult = _list([_notif('a')]);
      final cubit = _build(repo, local);

      await cubit.refreshNow();
      repo.listResult = _list([_notif('d', read: true), _notif('a')]);
      await cubit.refreshNow();

      expect(local.shownIds, isEmpty);
      await cubit.close();
    });

    test('reset clears the baseline so the next poll does not pop old items',
        () async {
      repo.listResult = _list([_notif('a')]);
      final cubit = _build(repo, local);

      await cubit.refreshNow(); // baseline {a}
      cubit.reset();
      await cubit.refreshNow(); // baseline again, no popup for a

      expect(local.shownIds, isEmpty);
      expect(cubit.state, isA<NotificationLoaded>());
      await cubit.close();
    });
  });
}
