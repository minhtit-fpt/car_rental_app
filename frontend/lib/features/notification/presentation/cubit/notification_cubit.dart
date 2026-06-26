import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/notifications/local_notification_service.dart';
import 'package:frontend/features/notification/domain/entities/notification.dart';
import 'package:frontend/features/notification/domain/usecases/list_notifications_usecase.dart';
import 'package:frontend/features/notification/domain/usecases/mark_all_read_usecase.dart';
import 'package:frontend/features/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:frontend/features/notification/presentation/cubit/notification_state.dart';

export 'package:frontend/features/notification/presentation/cubit/notification_state.dart';

/// Chu kỳ tự quét thông báo mới (poll) khi app đang mở.
const Duration _pollInterval = Duration(seconds: 30);

/// Quản lý danh sách thông báo + đánh dấu đã đọc + tự làm mới định kỳ và
/// hiện popup (local notification) cho thông báo mới chưa đọc.
///
/// Là **singleton** dùng chung toàn app: badge ở mọi nơi đọc cùng 1 state, và
/// chỉ 1 vòng poll chạy nền. Cơ chế poll (chưa phải push thật) nên popup chỉ
/// xuất hiện khi app còn sống (foreground/background ngắn).
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required ListNotificationsUseCase listNotifications,
    required MarkNotificationReadUseCase markRead,
    required MarkAllNotificationsReadUseCase markAllRead,
    required LocalNotificationService localNotifications,
  }) : _listNotifications = listNotifications,
       _markRead = markRead,
       _markAllRead = markAllRead,
       _localNotifications = localNotifications,
       super(const NotificationLoading());

  final ListNotificationsUseCase _listNotifications;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final LocalNotificationService _localNotifications;

  Timer? _pollTimer;
  // ID đã thấy — để phát hiện thông báo MỚI mà chưa popup lần nào.
  final Set<String> _seenIds = <String>{};
  // Lần fetch đầu chỉ lập "mốc nền", không popup hàng loạt noti cũ.
  bool _baselineSet = false;

  /// Bắt đầu tự làm mới định kỳ + bật popup cho noti mới. Gọi khi đăng nhập /
  /// khi app quay lại foreground. An toàn khi gọi lại (huỷ timer cũ trước).
  void startAutoRefresh() {
    _pollTimer?.cancel();
    unawaited(_fetch(allowPopups: true));
    _pollTimer = Timer.periodic(
      _pollInterval,
      (_) => unawaited(_fetch(allowPopups: true)),
    );
  }

  /// Dừng vòng poll (app vào nền / đăng xuất).
  void stopAutoRefresh() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Làm mới một lần (có thể bật popup cho noti mới) — không động tới timer.
  Future<void> refreshNow() => _fetch(allowPopups: true);

  /// Xoá trạng thái khi đăng xuất — tránh rò thông báo sang phiên khác.
  void reset() {
    stopAutoRefresh();
    _seenIds.clear();
    _baselineSet = false;
    emit(const NotificationLoading());
  }

  /// Nạp có spinner (mở màn danh sách / kéo làm mới). Không popup vì người
  /// dùng đang chủ động xem.
  Future<void> load() async {
    emit(const NotificationLoading());
    await _fetch(allowPopups: false);
  }

  Future<void> _fetch({required bool allowPopups}) async {
    try {
      final list = await _listNotifications();
      // Chỉ popup khi đã có mốc nền (đã từng fetch trước đó).
      if (allowPopups && _baselineSet) {
        for (final n in list.items) {
          if (!n.isRead && !_seenIds.contains(n.id)) {
            unawaited(_localNotifications.show(n));
          }
        }
      }
      _seenIds.addAll(list.items.map((n) => n.id));
      _baselineSet = true;
      emit(NotificationLoaded(list));
    } on ApiException catch (e) {
      // Lỗi khi poll không được xoá danh sách đang hiển thị.
      if (state is! NotificationLoaded) emit(NotificationError(e.message));
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
                  payload: n.payload,
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

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
