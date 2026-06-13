import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/features/booking/domain/booking_exception.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';
import 'package:frontend/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:frontend/features/booking/presentation/cubit/create_booking_cubit.dart';
import 'package:frontend/features/booking/presentation/cubit/create_booking_state.dart';

class MockCreateBookingUseCase extends Mock implements CreateBookingUseCase {}

class FakeCreateBookingParams extends Fake implements CreateBookingParams {}

void main() {
  late MockCreateBookingUseCase createBooking;

  final booking = Booking(
    id: 'book-1',
    vehicleId: 'veh-1',
    renterId: 'renter-1',
    status: BookingStatus.pendingPayment,
    startTime: DateTime.utc(2026, 7, 1, 8),
    endTime: DateTime.utc(2026, 7, 1, 12),
    totalPrice: 400,
    deliveryRequested: false,
    createdAt: DateTime.utc(2026, 6, 30),
  );

  final params = CreateBookingParams(
    vehicleId: 'veh-1',
    startTime: DateTime.utc(2026, 7, 1, 8),
    endTime: DateTime.utc(2026, 7, 1, 12),
  );

  setUpAll(() => registerFallbackValue(FakeCreateBookingParams()));
  setUp(() => createBooking = MockCreateBookingUseCase());

  CreateBookingCubit build() => CreateBookingCubit(createBooking);

  blocTest<CreateBookingCubit, CreateBookingState>(
    'submit emits [submitting, success] when the API succeeds',
    setUp: () =>
        when(() => createBooking(any())).thenAnswer((_) async => booking),
    build: build,
    act: (cubit) => cubit.submit(params),
    expect: () => [
      const CreateBookingSubmitting(),
      CreateBookingSuccess(booking),
    ],
  );

  blocTest<CreateBookingCubit, CreateBookingState>(
    'submit emits [submitting, failure] with the error code on conflict',
    setUp: () => when(() => createBooking(any())).thenThrow(
      const BookingException('Trùng giờ', code: 'BOOKING_CONFLICT'),
    ),
    build: build,
    act: (cubit) => cubit.submit(params),
    expect: () => [
      const CreateBookingSubmitting(),
      const CreateBookingFailure('Trùng giờ', code: 'BOOKING_CONFLICT'),
    ],
  );

  blocTest<CreateBookingCubit, CreateBookingState>(
    'submit ignores re-entry while already submitting',
    setUp: () => when(() => createBooking(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return booking;
    }),
    build: build,
    act: (cubit) {
      cubit.submit(params);
      cubit.submit(params); // second call should be ignored
    },
    wait: const Duration(milliseconds: 50),
    expect: () => [
      const CreateBookingSubmitting(),
      CreateBookingSuccess(booking),
    ],
    verify: (_) => verify(() => createBooking(any())).called(1),
  );
}
