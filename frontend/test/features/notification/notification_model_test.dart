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

  group('AppNotification.targetRoute', () {
    AppNotification make(NotificationType type, Map<String, dynamic>? payload) =>
        AppNotification(
          id: 'n-1',
          type: type,
          title: 't',
          createdAt: DateTime(2026),
          payload: payload,
        );

    test('routes owner booking/payment to booking-request', () {
      expect(
        make(NotificationType.booking, {'role': 'owner'}).targetRoute,
        '/owner/booking-request',
      );
      expect(
        make(NotificationType.payment, {'role': 'owner'}).targetRoute,
        '/owner/booking-request',
      );
    });

    test('routes renter booking/payment to trips', () {
      expect(
        make(NotificationType.booking, {'bookingId': 'b'}).targetRoute,
        '/trips',
      );
      expect(make(NotificationType.payment, null).targetRoute, '/trips');
    });
  });
}
