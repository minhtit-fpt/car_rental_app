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

  // Mọi thay đổi lựa chọn đều huỷ bản nháp đơn đã tạo (resetSubmission) để lần
  // xác nhận sau tạo đơn mới đúng lựa chọn, không dùng lại đơn cũ.
  void setDates(DateTime start, DateTime end) {
    emit(state.copyWith(startDate: start, endDate: end, resetSubmission: true));
  }

  void toggleDelivery({required bool value}) {
    emit(state.copyWith(withDelivery: value, resetSubmission: true));
  }

  void setDeliveryAddress(String address) {
    emit(state.copyWith(deliveryAddress: address, resetSubmission: true));
  }

  void signContract() {
    emit(state.copyWith(contractSigned: true));
  }

  /// Tạo đơn trên backend (`POST /api/bookings`). Đặt [submitted] = true khi
  /// thành công để màn xác nhận điều hướng sang bước hợp đồng.
  Future<void> confirmBooking({required String vehicleId}) async {
    if (!state.datesSelected || state.isSubmitting) return;

    // Đã tạo đơn cho đúng lựa chọn này rồi → KHÔNG tạo trùng. Chỉ phát lại
    // chuyển `submitted` (false→true) để màn xác nhận điều hướng tiếp bằng đơn
    // cũ. Ngăn lỗi "bấm bao nhiêu lần đặt bấy nhiêu lần" khi quay lại bấm lại.
    if (state.booking != null) {
      emit(state.copyWith(submitted: false));
      emit(state.copyWith(submitted: true));
      return;
    }

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
        state.copyWith(isSubmitting: false, submitted: true, booking: booking),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    }
  }
}
