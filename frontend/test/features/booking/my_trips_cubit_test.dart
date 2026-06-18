import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';
import 'package:frontend/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:frontend/features/booking/domain/usecases/list_bookings_usecase.dart';
import 'package:frontend/features/booking/presentation/cubit/my_trips_cubit.dart';

Booking _booking(String id, BookingStatus status) => Booking(
  id: id,
  vehicleId: 'v1',
  renterId: 'u1',
  status: status,
  startTime: DateTime.utc(2026, 1, 1),
  endTime: DateTime.utc(2026, 1, 2),
  totalPrice: 1200000,
  deliveryRequested: false,
  createdAt: DateTime.utc(2026, 1, 1),
);

/// Fake cấu hình được — không chạm mạng.
class _FakeBookingRepository implements BookingRepository {
  List<Booking> listResult = const [];
  Object? listError;
  Booking? cancelResult;
  Object? cancelError;

  @override
  Future<Booking> createBooking({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
    bool deliveryRequested = false,
  }) => throw UnimplementedError();

  @override
  Future<List<Booking>> listBookings({
    BookingStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    if (listError != null) throw listError!;
    return listResult;
  }

  @override
  Future<Booking> getBooking(String id) => throw UnimplementedError();

  @override
  Future<Booking> cancelBooking(String id) async {
    if (cancelError != null) throw cancelError!;
    return cancelResult!;
  }
}

MyTripsCubit _build(_FakeBookingRepository repo) => MyTripsCubit(
  listBookings: ListBookingsUseCase(repo),
  cancelBooking: CancelBookingUseCase(repo),
);

void main() {
  group('MyTripsCubit', () {
    late _FakeBookingRepository repo;

    setUp(() => repo = _FakeBookingRepository());

    blocTest<MyTripsCubit, MyTripsState>(
      'load success emits loading then loaded with bookings',
      build: () {
        repo.listResult = [_booking('b1', BookingStatus.confirmed)];
        return _build(repo);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<MyTripsLoading>(),
        isA<MyTripsLoaded>().having((s) => s.bookings.length, 'count', 1),
      ],
    );

    blocTest<MyTripsCubit, MyTripsState>(
      'load failure surfaces the API error message',
      build: () {
        repo.listError = const ApiException('Lỗi máy chủ', code: 'SERVER_ERROR');
        return _build(repo);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<MyTripsLoading>(),
        isA<MyTripsError>().having((s) => s.message, 'message', 'Lỗi máy chủ'),
      ],
    );

    blocTest<MyTripsCubit, MyTripsState>(
      'cancel replaces the booking with the updated (cancelled) one',
      build: () {
        repo.cancelResult = _booking('b1', BookingStatus.cancelled);
        return _build(repo);
      },
      seed: () => MyTripsLoaded([_booking('b1', BookingStatus.confirmed)]),
      act: (cubit) => cubit.cancel('b1'),
      expect: () => [
        isA<MyTripsLoaded>().having((s) => s.cancellingId, 'cancellingId', 'b1'),
        isA<MyTripsLoaded>()
            .having((s) => s.bookings.first.status, 'status',
                BookingStatus.cancelled)
            .having((s) => s.cancellingId, 'cancellingId', null),
      ],
    );
  });
}
