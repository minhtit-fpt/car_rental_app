import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/notification/domain/entities/notification.dart';
import 'package:frontend/features/notification/domain/usecases/list_notifications_usecase.dart';
import 'package:frontend/features/notification/domain/usecases/mark_all_read_usecase.dart';
import 'package:frontend/features/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:frontend/features/notification/presentation/cubit/notification_state.dart';

export 'package:frontend/features/notification/presentation/cubit/notification_state.dart';

/// Quản lý danh sách thông báo + thao tác đánh dấu đã đọc.
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required ListNotificationsUseCase listNotifications,
    required MarkNotificationReadUseCase markRead,
    required MarkAllNotificationsReadUseCase markAllRead,
  }) : _listNotifications = listNotifications,
       _markRead = markRead,
       _markAllRead = markAllRead,
       super(const NotificationLoading());

  final ListNotificationsUseCase _listNotifications;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;

  Future<void> load() async {
    emit(const NotificationLoading());
    try {
      emit(NotificationLoaded(await _listNotifications()));
    } on ApiException catch (e) {
      emit(NotificationError(e.message));
    }
  }

  Future<void> markRead(String id) async {
    final current = state;
    if (current is! NotificationLoaded) return;
    try {
      final unreadCount = await _markRead(id);
      emit(NotificationLoaded(_applyRead(current.data, {id}, unreadCount)));
    } on ApiException {
      // Bỏ qua lỗi đánh dấu đọc — không phá trạng thái danh sách hiện có.
    }
  }

  Future<void> markAllRead() async {
    final current = state;
    if (current is! NotificationLoaded) return;
    try {
      await _markAllRead();
      final ids = current.data.items.map((n) => n.id).toSet();
      emit(NotificationLoaded(_applyRead(current.data, ids, 0)));
    } on ApiException {
      // Bỏ qua lỗi — danh sách giữ nguyên.
    }
  }

  NotificationList _applyRead(
    NotificationList data,
    Set<String> ids,
    int unreadCount,
  ) {
    final now = DateTime.now();
    final items = data.items
        .map(
          (n) => ids.contains(n.id) && !n.isRead
              ? AppNotification(
                  id: n.id,
                  type: n.type,
                  title: n.title,
                  body: n.body,
                  createdAt: n.createdAt,
                  readAt: now,
                )
              : n,
        )
        .toList(growable: false);
    return NotificationList(
      items: items,
      total: data.total,
      unreadCount: unreadCount,
      page: data.page,
      limit: data.limit,
    );
  }
}
