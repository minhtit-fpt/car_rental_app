import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/features/booking/domain/booking_exception.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:frontend/features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'package:frontend/features/booking/presentation/cubit/my_trips_cubit.dart';
import 'package:frontend/features/booking/presentation/cubit/my_trips_state.dart';

class MockGetMyBookingsUseCase extends Mock implements GetMyBookingsUseCase {}

class MockCancelBookingUseCase extends Mock implements CancelBookingUseCase {}

Booking _booking({
  String id = 'book-1',
  BookingStatus status = BookingStatus.pendingPayment,
}) {
  return Booking(
    id: id,
    vehicleId: 'veh-1',
    renterId: 'renter-1',
    status: status,
    startTime: DateTime.utc(2026, 7, 1, 8),
    endTime: DateTime.utc(2026, 7, 1, 12),
    totalPrice: 400,
    deliveryRequested: false,
    createdAt: DateTime.utc(2026, 6, 30),
  );
}

void main() {
  late MockGetMyBookingsUseCase getMyBookings;
  late MockCancelBookingUseCase cancelBooking;

  setUp(() {
    getMyBookings = MockGetMyBookingsUseCase();
    cancelBooking = MockCancelBookingUseCase();
  });

  MyTripsCubit build() => MyTripsCubit(
        getMyBookings: getMyBookings,
        cancelBooking: cancelBooking,
      );

  blocTest<MyTripsCubit, MyTripsState>(
    'load emits [loading, loaded] with the renter bookings',
    setUp: () => when(
      () => getMyBookings(
        status: any(named: 'status'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => [_booking()]),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const MyTripsLoading(),
      MyTripsLoaded(items: [_booking()]),
    ],
  );

  blocTest<MyTripsCubit, MyTripsState>(
    'load emits [loading, error] on failure',
    setUp: () => when(
      () => getMyBookings(
        status: any(named: 'status'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(const BookingException('boom')),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const MyTripsLoading(),
      const MyTripsError('boom'),
    ],
  );

  blocTest<MyTripsCubit, MyTripsState>(
    'cancel replaces the booking in place on success',
    setUp: () {
      when(
        () => getMyBookings(
          status: any(named: 'status'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => [_booking()]);
      when(() => cancelBooking('book-1')).thenAnswer(
        (_) async => _booking(status: BookingStatus.cancelled),
      );
    },
    build: build,
    act: (cubit) async {
      await cubit.load();
      await cubit.cancel('book-1');
    },
    expect: () => [
      const MyTripsLoading(),
      MyTripsLoaded(items: [_booking()]),
      MyTripsLoaded(items: [_booking()], cancellingId: 'book-1'),
      MyTripsLoaded(items: [_booking(status: BookingStatus.cancelled)]),
    ],
  );

  blocTest<MyTripsCubit, MyTripsState>(
    'cancel rolls back the cancelling flag on failure',
    setUp: () {
      when(
        () => getMyBookings(
          status: any(named: 'status'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => [_booking()]);
      when(() => cancelBooking('book-1'))
          .thenThrow(const BookingException('Không thể huỷ'));
    },
    build: build,
    act: (cubit) async {
      await cubit.load();
      await cubit.cancel('book-1');
    },
    expect: () => [
      const MyTripsLoading(),
      MyTripsLoaded(items: [_booking()]),
      MyTripsLoaded(items: [_booking()], cancellingId: 'book-1'),
      MyTripsLoaded(items: [_booking()]),
    ],
  );
}
