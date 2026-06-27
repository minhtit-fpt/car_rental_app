import 'package:frontend/features/notification/domain/entities/notification.dart';

/// Ánh xạ JSON `PublicNotification` / `NotificationListResult` → entity.
abstract final class NotificationModel {
  static NotificationType _typeFromJson(String raw) => switch (raw) {
    'BOOKING' => NotificationType.booking,
    'PAYMENT' => NotificationType.payment,
    'KYC' => NotificationType.kyc,
    'CHAT' => NotificationType.chat,
    'PROMOTION' => NotificationType.promotion,
    _ => NotificationType.system,
  };

  static AppNotification fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as String,
    type: _typeFromJson(json['type'] as String),
    title: json['title'] as String,
    body: json['body'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    readAt: json['readAt'] == null
        ? null
        : DateTime.parse(json['readAt'] as String),
    payload: json['payload'] is Map
        ? Map<String, dynamic>.from(json['payload'] as Map)
        : null,
  );

  static NotificationList listFromJson(Map<String, dynamic> json) =>
      NotificationList(
        items: (json['items'] as List<dynamic>)
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        total: json['total'] as int,
        unreadCount: json['unreadCount'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
      );
}
