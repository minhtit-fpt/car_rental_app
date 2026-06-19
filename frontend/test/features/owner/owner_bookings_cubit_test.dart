import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/owner/domain/entities/owner_booking.dart';
import 'package:frontend/features/owner/domain/repositories/owner_repository.dart';
import 'package:frontend/features/owner/domain/entities/owner_revenue.dart';
import 'package:frontend/features/owner/domain/usecases/approve_booking_usecase.dart';
import 'package:frontend/features/owner/domain/usecases/list_owner_bookings_usecase.dart';
import 'package:frontend/features/owner/domain/usecases/reject_booking_usecase.dart';
import 'package:frontend/features/owner/presentation/cubit/owner_bookings_cubit.dart';

OwnerBooking _booking({
  String id = 'b1',
  BookingStatus status = BookingStatus.pendingPayment,
}) => OwnerBooking(
  id: id,
  status: status,
  startTime: DateTime.parse('2026-07-01T08:00:00Z'),
  endTime: DateTime.parse('2026-07-01T12:00:00Z'),
  totalPrice: 400000,
  deliveryRequested: false,
  createdAt: DateTime.parse('2026-06-18T00:00:00Z'),
  vehicleId: 'v1',
  vehicleTitle: 'VF8',
  vehicleType: 'CAR',
  renterId: 'r1',
  renterPhone: '0900000000',
  renterEmail: null,
);

/// Fake cấu hình được — không chạm mạng.
class _FakeOwnerRepository implements OwnerRepository {
  List<OwnerBooking> listResult = const [];
  Object? listError;
  OwnerBooking? actionResult;
  Object? actionError;

  @override
  Future<List<OwnerBooking>> listBookings({
    BookingStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    if (listError != null) throw listError!;
    return listResult;
  }

  @override
  Future<OwnerBooking> approve(String id) async {
    if (actionError != null) throw actionError!;
    return actionResult!;
  }

  @override
  Future<OwnerBooking> reject(String id) async {
    if (actionError != null) throw actionError!;
    return actionResult!;
  }

  @override
  Future<OwnerRevenue> getRevenue({int months = 6}) =>
      throw UnimplementedError();
}

OwnerBookingsCubit _build(_FakeOwnerRepository repo) => OwnerBookingsCubit(
  listBookings: ListOwnerBookingsUseCase(repo),
  approveBooking: ApproveBookingUseCase(repo),
  rejectBooking: RejectBookingUseCase(repo),
);

void main() {
  group('OwnerBookingsCubit', () {
    test('starts in loading state', () {
      expect(_build(_FakeOwnerRepository()).state, isA<OwnerBookingsLoading>());
    });

    blocTest<OwnerBookingsCubit, OwnerBookingsState>(
      'load success emits loading then loaded with bookings',
      build: () {
        final repo = _FakeOwnerRepository()..listResult = [_booking()];
        return _build(repo);
      },
      act: (c) => c.load(),
      expect: () => [
        isA<OwnerBookingsLoading>(),
        isA<OwnerBookingsLoaded>().having(
          (s) => s.pending.length,
          'pending count',
          1,
        ),
      ],
    );

    blocTest<OwnerBookingsCubit, OwnerBookingsState>(
      'approve replaces the booking with the confirmed one',
      build: () {
        final repo = _FakeOwnerRepository()
          ..listResult = [_booking()]
          ..actionResult = _booking(status: BookingStatus.confirmed);
        return _build(repo);
      },
      act: (c) async {
        await c.load();
        await c.approve('b1');
      },
      skip: 2,
      expect: () => [
        // actingId được đặt trong khi chờ
        isA<OwnerBookingsLoaded>().having((s) => s.actingId, 'actingId', 'b1'),
        // kết quả: đơn chuyển sang confirmed, không còn pending
        isA<OwnerBookingsLoaded>().having(
          (s) => s.pending.length,
          'pending count',
          0,
        ),
      ],
    );

    blocTest<OwnerBookingsCubit, OwnerBookingsState>(
      'reject surfaces API error',
      build: () {
        final repo = _FakeOwnerRepository()
          ..listResult = [_booking()]
          ..actionError = const ApiException('Không thể từ chối');
        return _build(repo);
      },
      act: (c) async {
        await c.load();
        await c.reject('b1');
      },
      skip: 2,
      expect: () => [
        isA<OwnerBookingsLoaded>().having((s) => s.actingId, 'actingId', 'b1'),
        isA<OwnerBookingsError>().having(
          (s) => s.message,
          'message',
          'Không thể từ chối',
        ),
      ],
    );
  });
}
