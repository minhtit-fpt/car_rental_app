import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/features/notification/domain/entities/notification.dart';

/// Bọc plugin `flutter_local_notifications` để hiện thông báo ở khay hệ thống.
///
/// Đây là cơ chế **poll-based** (NotificationCubit quét định kỳ rồi gọi [show]),
/// chưa phải push thật từ server. Hoạt động khi app đang foreground/background;
/// app bị kill thì timer không chạy nên sẽ không có popup tới khi mở lại.
class LocalNotificationService {
  LocalNotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Channel mặc định (Android 8+). Tên/desc hiển thị trong cài đặt hệ thống.
  static const String _channelId = 'ridevn_default';
  static const String _channelName = 'Thông báo RideVN';
  static const String _channelDescription =
      'Thông báo đặt xe, thanh toán và hệ thống';

  /// Khởi tạo plugin + tạo channel + xin quyền. An toàn khi gọi nhiều lần.
  /// [onSelect] nhận payload (bookingId) khi người dùng chạm vào thông báo.
  Future<void> init({void Function(String? payload)? onSelect}) async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) =>
          onSelect?.call(response.payload),
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );
    // Android 13+ cần xin POST_NOTIFICATIONS lúc runtime.
    await android?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Hiện 1 thông báo ở khay hệ thống cho [notif]. No-op nếu chưa [init].
  Future<void> show(AppNotification notif) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    // id ổn định theo notif.id để tránh hiện trùng cùng 1 thông báo.
    final id = notif.id.hashCode & 0x7fffffff;
    await _plugin.show(
      id,
      notif.title,
      notif.body,
      details,
      payload: notif.bookingId,
    );
  }
}
