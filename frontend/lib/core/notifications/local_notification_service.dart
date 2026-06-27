import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Hợp đồng tối thiểu để phát popup — giúp tầng cubit không phụ thuộc trực tiếp
/// vào package `flutter_local_notifications`.
abstract interface class NotificationPopup {
  Future<void> show({
    required int id,
    required String title,
    String? body,
    String? payload,
  });
}

/// Phát popup thông báo trên khay hệ thống (OS) qua `flutter_local_notifications`.
class LocalNotificationService implements NotificationPopup {
  static const _channelId = 'ridevn_default';
  static const _channelName = 'Thông báo RideVN';
  static const _channelDesc = 'Thông báo đặt xe, thanh toán, KYC và tin nhắn';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// Khởi tạo plugin + tạo channel Android. [onTap] nhận `payload` (route đích)
  /// khi người dùng chạm vào popup ở khay hệ thống.
  Future<void> init({void Function(String? payload)? onTap}) async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
      onDidReceiveNotificationResponse: (response) =>
          onTap?.call(response.payload),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );
    _ready = true;
  }

  /// Xin quyền thông báo (Android 13+ và iOS). An toàn gọi nhiều lần.
  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    String? body,
    String? payload,
  }) async {
    if (!_ready) return;
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }
}
