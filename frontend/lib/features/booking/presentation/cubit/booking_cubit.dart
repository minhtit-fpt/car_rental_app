import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/booking/domain/entities/booking_state.dart';
import 'package:frontend/features/booking/domain/usecases/create_booking_usecase.dart';

export 'package:frontend/features/booking/domain/entities/booking_state.dart';

class BookingCubit extends Cubit<BookingFormState> {
  BookingCubit({required CreateBookingUseCase createBooking})
    : _createBooking = createBooking,
      super(const BookingFormState());

  final CreateBookingUseCase _createBooking;

  void setDates(DateTime start, DateTime end) {
    emit(state.copyWith(startDate: start, endDate: end));
  }

  void toggleDelivery({required bool value}) {
    emit(state.copyWith(withDelivery: value));
  }

  void setDeliveryAddress(String address) {
    emit(state.copyWith(deliveryAddress: address));
  }

  void signContract() {
    emit(state.copyWith(contractSigned: true));
  }

  /// Tạo đơn trên backend (`POST /api/bookings`). Đặt [submitted] = true khi
  /// thành công để màn xác nhận điều hướng sang bước hợp đồng.
  Future<void> confirmBooking({required String vehicleId}) async {
    if (!state.datesSelected || state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    // endTime phải sau startTime (validator backend). Suy ra từ số ngày đã chọn
    // để luôn hợp lệ kể cả khi người dùng chọn đúng 1 ngày.
    final start = state.startDate!;
    final end = start.add(Duration(days: state.totalDays));

    try {
      final booking = await _createBooking(
        vehicleId: vehicleId,
        startTime: start,
        endTime: end,
        deliveryRequested: state.withDelivery,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          submitted: true,
          booking: booking,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    }
  }
}
