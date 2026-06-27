import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notification/data/models/notification_model.dart';
import 'package:frontend/features/notification/domain/entities/notification.dart';

void main() {
  group('NotificationModel.fromJson', () {
    Map<String, dynamic> baseJson() => {
      'id': 'n-1',
      'type': 'BOOKING',
      'title': 'Yêu cầu đặt xe mới',
      'body': 'Nội dung',
      'createdAt': '2026-06-01T00:00:00.000Z',
      'readAt': null,
    };

    test('maps the navigation payload when present', () {
      final notif = NotificationModel.fromJson({
        ...baseJson(),
        'payload': {'bookingId': 'b-1', 'role': 'owner'},
      });

      expect(notif.type, NotificationType.booking);
      expect(notif.payload, {'bookingId': 'b-1', 'role': 'owner'});
    });

    test('leaves payload null when missing or not an object', () {
      expect(NotificationModel.fromJson(baseJson()).payload, isNull);
      expect(
        NotificationModel.fromJson({...baseJson(), 'payload': null}).payload,
        isNull,
      );
    });

    test('parses chat conversation payload', () {
      final notif = NotificationModel.fromJson({
        ...baseJson(),
        'type': 'CHAT',
        'payload': {'conversationId': 'c-9'},
      });

      expect(notif.type, NotificationType.chat);
      expect(notif.payload?['conversationId'], 'c-9');
    });
  });
}
