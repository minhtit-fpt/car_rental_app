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

/// Chu kỳ tự kiểm tra thông báo mới khi app đang mở (foreground).
const _pollInterval = Duration(seconds: 30);

/// Quản lý danh sách thông báo + tự refresh định kỳ + phát popup khay OS khi có
/// thông báo chưa đọc mới. Là **singleton** (provide ở app root).
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required ListNotificationsUseCase listNotifications,
    required MarkNotificationReadUseCase markRead,
    required MarkAllNotificationsReadUseCase markAllRead,
    required NotificationPopup popup,
  }) : _listNotifications = listNotifications,
       _markRead = markRead,
       _markAllRead = markAllRead,
       _popup = popup,
       super(const NotificationLoading());

  final ListNotificationsUseCase _listNotifications;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final NotificationPopup _popup;

  Timer? _timer;
  bool _polling = false;
  // Lần fetch đầu sau khi đăng nhập chỉ tạo "mốc" — không popup thông báo cũ.
  bool _baselineSet = false;
  final Set<String> _poppedIds = {};

  /// Bắt đầu tự refresh (gọi khi đăng nhập / app quay lại foreground).
  void startAutoRefresh() {
    if (_polling) return;
    _polling = true;
    unawaited(_poll());
    _timer = Timer.periodic(_pollInterval, (_) => unawaited(_poll()));
  }

  /// Dừng tự refresh (gọi khi app vào nền). Giữ nguyên mốc đã đọc.
  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
    _polling = false;
  }

  /// Xoá trạng thái khi đăng xuất — lần đăng nhập sau sẽ tạo mốc lại.
  void reset() {
    stopAutoRefresh();
    _baselineSet = false;
    _poppedIds.clear();
    emit(const NotificationLoading());
  }

  /// Tải có hiển thị trạng thái (dùng khi mở màn hình thông báo).
  Future<void> load() async {
    emit(const NotificationLoading());
    await _fetch(allowPopups: false);
  }

  Future<void> _fetch({required bool allowPopups}) async {
    try {
      _handleData(await _listNotifications());
    } on ApiException catch (e) {
      // Lỗi khi poll không được xoá danh sách đang hiển thị.
      if (state is! NotificationLoaded) emit(NotificationError(e.message));
    }
  }

  /// Refresh ngay lập tức — gọi sau khi người dùng vừa đặt xe / thanh toán
  /// xong để dấu đỏ ở chuông + popup tới ngay, không phải đợi chu kỳ poll 30s.
  Future<void> refresh() => _poll();

  /// Refresh nền — im lặng, không lật sang Loading/Error để tránh nhấp nháy.
  Future<void> _poll() async {
    try {
      _handleData(await _listNotifications());
    } on ApiException {
      // Bỏ qua lỗi mạng tạm thời khi chạy nền.
    }
  }

  void _handleData(NotificationList data) {
    final unread = data.items.where((n) => !n.isRead);
    if (_baselineSet) {
      for (final n in unread) {
        if (_poppedIds.add(n.id)) _showPopup(n);
      }
    } else {
      _poppedIds.addAll(unread.map((n) => n.id));
      _baselineSet = true;
    }
    emit(NotificationLoaded(data));
  }

  void _showPopup(AppNotification n) {
    unawaited(
      _popup.show(
        id: n.id.hashCode,
        title: n.title,
        body: n.body,
        payload: n.targetRoute,
      ),
    );
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
    _timer?.cancel();
    return super.close();
  }
}
