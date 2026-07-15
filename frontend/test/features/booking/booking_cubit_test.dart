import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';
import 'package:frontend/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:frontend/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/price_quote.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:frontend/features/vehicle/domain/usecases/get_price_quote_usecase.dart';

Booking _booking(String id) => Booking(
  id: id,
  vehicleId: 'veh1',
  renterId: 'renter1',
  status: BookingStatus.pendingPayment,
  startTime: DateTime(2026, 7, 1),
  endTime: DateTime(2026, 7, 3),
  totalPrice: 1000000,
  deliveryRequested: false,
  createdAt: DateTime(2026, 6, 26),
);

/// Fake đếm số lần POST tạo đơn — để phát hiện đơn trùng.
class _FakeBookingRepository implements BookingRepository {
  int createCount = 0;

  @override
  Future<Booking> createBooking({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
    bool deliveryRequested = false,
  }) async {
    createCount += 1;
    return _booking('book$createCount');
  }

  @override
  Future<List<Booking>> listBookings({
    BookingStatus? status,
    int page = 1,
    int limit = 20,
  }) async => const [];

  @override
  Future<Booking> getBooking(String id) async => _booking(id);

  @override
  Future<Booking> cancelBooking(String id) async => _booking(id);
}

class _StubVehicleRepository implements VehicleRepository {
  @override
  Future<PriceQuote> getPriceQuote({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
  }) async =>
      const PriceQuote(
        basePricePerDay: 50000,
        days: 1,
        basePrice: 50000,
        factors: [],
        finalPrice: 50000,
        currency: 'VND',
      );

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

BookingCubit _cubit(_FakeBookingRepository repo) => BookingCubit(
      createBooking: CreateBookingUseCase(repo),
      getPriceQuote: GetPriceQuoteUseCase(_StubVehicleRepository()),
    );

void main() {
  group('BookingCubit.confirmBooking — chống đặt trùng', () {
    test('bấm nhiều lần với cùng lựa chọn chỉ tạo đơn một lần', () async {
      final repo = _FakeBookingRepository();
      final cubit = _cubit(repo)
        ..setDates(DateTime(2026, 7, 1), DateTime(2026, 7, 3));
      addTearDown(cubit.close);

      await cubit.confirmBooking(vehicleId: 'veh1');
      await cubit.confirmBooking(vehicleId: 'veh1');
      await cubit.confirmBooking(vehicleId: 'veh1');

      expect(repo.createCount, 1, reason: '3 lần bấm chỉ được 1 đơn');
      expect(cubit.state.booking?.id, 'book1');
      expect(cubit.state.submitted, isTrue);
    });

    blocTest<BookingCubit, BookingFormState>(
      'lần bấm thứ hai vẫn phát lại submitted để màn xác nhận điều hướng tiếp',
      build: () => _cubit(_FakeBookingRepository()),
      seed: () => const BookingFormState(),
      act: (cubit) async {
        cubit.setDates(DateTime(2026, 7, 1), DateTime(2026, 7, 3));
        await cubit.confirmBooking(vehicleId: 'veh1');
        await cubit.confirmBooking(vehicleId: 'veh1');
      },
      verify: (cubit) {
        // Phải có ít nhất một chuyển submitted false→true ở lần thứ hai.
        expect(cubit.state.submitted, isTrue);
        expect(cubit.state.booking, isNotNull);
      },
    );

    test('đổi ngày sau khi đã tạo đơn thì tạo đơn mới', () async {
      final repo = _FakeBookingRepository();
      final cubit = _cubit(repo)
        ..setDates(DateTime(2026, 7, 1), DateTime(2026, 7, 3));
      addTearDown(cubit.close);

      await cubit.confirmBooking(vehicleId: 'veh1');
      expect(repo.createCount, 1);

      // Người dùng quay lại đổi ngày → bản nháp cũ phải bị huỷ.
      cubit.setDates(DateTime(2026, 8, 1), DateTime(2026, 8, 4));
      expect(cubit.state.booking, isNull, reason: 'đổi ngày huỷ đơn nháp cũ');

      await cubit.confirmBooking(vehicleId: 'veh1');
      expect(repo.createCount, 2, reason: 'lựa chọn mới → đơn mới');
    });
  });
}
