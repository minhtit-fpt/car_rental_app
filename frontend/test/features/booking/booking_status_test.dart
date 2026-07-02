import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';

void main() {
  group('BookingStatus.fromApi', () {
    test('parses AWAITING_OWNER', () {
      expect(
        BookingStatus.fromApi('AWAITING_OWNER'),
        BookingStatus.awaitingOwner,
      );
    });

    test('parses the other known statuses', () {
      expect(BookingStatus.fromApi('PENDING_PAYMENT'),
          BookingStatus.pendingPayment);
      expect(BookingStatus.fromApi('CONFIRMED'), BookingStatus.confirmed);
      expect(BookingStatus.fromApi('CANCELLED'), BookingStatus.cancelled);
    });

    test('falls back to unknown for unrecognised values', () {
      expect(BookingStatus.fromApi('SOMETHING_ELSE'), BookingStatus.unknown);
      expect(BookingStatus.fromApi(null), BookingStatus.unknown);
    });
  });
}
