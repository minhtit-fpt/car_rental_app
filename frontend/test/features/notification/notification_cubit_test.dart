import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/notifications/local_notification_service.dart';
import 'package:frontend/features/notification/domain/entities/notification.dart';
import 'package:frontend/features/notification/domain/repositories/notification_repository.dart';
import 'package:frontend/features/notification/domain/usecases/list_notifications_usecase.dart';
import 'package:frontend/features/notification/domain/usecases/mark_all_read_usecase.dart';
import 'package:frontend/features/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:frontend/features/notification/presentation/cubit/notification_cubit.dart';

class _FakeRepo implements NotificationRepository {
  NotificationList result = const NotificationList(
    items: [],
    total: 0,
    unreadCount: 0,
    page: 1,
    limit: 20,
  );

  @override
  Future<NotificationList> list({int page = 1, int limit = 20}) async => result;

  @override
  Future<int> markRead(String id) async => 0;

  @override
  Future<void> markAllRead() async {}
}

class _RecordingPopup implements NotificationPopup {
  final List<String> shownTitles = [];

  @override
  Future<void> show({
    required int id,
    required String title,
    String? body,
    String? payload,
  }) async {
    shownTitles.add(title);
  }
}

AppNotification _notif(String id, {bool read = false}) => AppNotification(
  id: id,
  type: NotificationType.booking,
  title: 'Noti $id',
  createdAt: DateTime(2026, 6, 27),
  readAt: read ? DateTime(2026, 6, 27) : null,
);

NotificationList _list(List<AppNotification> items) => NotificationList(
  items: items,
  total: items.length,
  unreadCount: items.where((n) => !n.isRead).length,
  page: 1,
  limit: 20,
);

void main() {
  late _FakeRepo repo;
  late _RecordingPopup popup;
  late NotificationCubit cubit;

  setUp(() {
    repo = _FakeRepo();
    popup = _RecordingPopup();
    cubit = NotificationCubit(
      listNotifications: ListNotificationsUseCase(repo),
      markRead: MarkNotificationReadUseCase(repo),
      markAllRead: MarkAllNotificationsReadUseCase(repo),
      popup: popup,
    );
  });

  tearDown(() => cubit.close());

  test('first load sets a baseline and does NOT popup existing unread', () async {
    repo.result = _list([_notif('a'), _notif('b')]);

    await cubit.load();

    expect(cubit.state, isA<NotificationLoaded>());
    expect(popup.shownTitles, isEmpty);
  });

  test('a new unread notification on a later refresh fires a popup', () async {
    repo.result = _list([_notif('a')]);
    await cubit.load(); // baseline

    repo.result = _list([_notif('b'), _notif('a')]); // 'b' is new
    await cubit.load();

    expect(popup.shownTitles, ['Noti b']);
  });

  test('the same unread notification is not popped twice', () async {
    repo.result = _list([_notif('a')]);
    await cubit.load(); // baseline

    repo.result = _list([_notif('b'), _notif('a')]);
    await cubit.load(); // pops 'b'
    await cubit.load(); // 'b' already popped

    expect(popup.shownTitles, ['Noti b']);
  });

  test('refresh() pops a newly created notification immediately', () async {
    repo.result = _list([_notif('a')]);
    await cubit.load(); // baseline

    repo.result = _list([_notif('pay'), _notif('a')]); // new after payment
    await cubit.refresh();

    expect(popup.shownTitles, ['Noti pay']);
    expect(cubit.state, isA<NotificationLoaded>());
  });

  test('reset re-baselines so old unread does not re-popup', () async {
    repo.result = _list([_notif('a')]);
    await cubit.load(); // baseline with 'a'

    cubit.reset();
    repo.result = _list([_notif('a')]); // same 'a' after re-login
    await cubit.load();

    expect(popup.shownTitles, isEmpty);
  });
}
