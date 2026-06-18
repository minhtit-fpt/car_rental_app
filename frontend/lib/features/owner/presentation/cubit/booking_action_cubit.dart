import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/owner/domain/usecases/approve_booking_usecase.dart';
import 'package:frontend/features/owner/domain/usecases/reject_booking_usecase.dart';

sealed class BookingActionState {
  const BookingActionState();
}

final class BookingActionIdle extends BookingActionState {
  const BookingActionIdle();
}

final class BookingActionInProgress extends BookingActionState {
  const BookingActionInProgress();
}

final class BookingActionDone extends BookingActionState {
  const BookingActionDone(this.status);

  /// Trạng thái mới sau khi xử lý (CONFIRMED nếu chấp nhận, CANCELLED nếu từ chối).
  final BookingStatus status;
}

final class BookingActionError extends BookingActionState {
  const BookingActionError(this.message);
  final String message;
}

/// Xử lý một lần chấp nhận/từ chối yêu cầu đặt (màn chi tiết yêu cầu).
class BookingActionCubit extends Cubit<BookingActionState> {
  BookingActionCubit({
    required ApproveBookingUseCase approveBooking,
    required RejectBookingUseCase rejectBooking,
  }) : _approveBooking = approveBooking,
       _rejectBooking = rejectBooking,
       super(const BookingActionIdle());

  final ApproveBookingUseCase _approveBooking;
  final RejectBookingUseCase _rejectBooking;

  Future<void> approve(String id) async {
    if (state is BookingActionInProgress) return;
    emit(const BookingActionInProgress());
    try {
      final updated = await _approveBooking(id);
      emit(BookingActionDone(updated.status));
    } on ApiException catch (e) {
      emit(BookingActionError(e.message));
    }
  }

  Future<void> reject(String id) async {
    if (state is BookingActionInProgress) return;
    emit(const BookingActionInProgress());
    try {
      final updated = await _rejectBooking(id);
      emit(BookingActionDone(updated.status));
    } on ApiException catch (e) {
      emit(BookingActionError(e.message));
    }
  }
}
