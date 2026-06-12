import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/booking/domain/booking_exception.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';
import 'package:frontend/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:frontend/features/booking/presentation/cubit/create_booking_state.dart';

class CreateBookingCubit extends Cubit<CreateBookingState> {
  CreateBookingCubit(this._createBooking) : super(const CreateBookingIdle());

  final CreateBookingUseCase _createBooking;

  Future<void> submit(CreateBookingParams params) async {
    if (state is CreateBookingSubmitting) return;
    emit(const CreateBookingSubmitting());
    try {
      final booking = await _createBooking(params);
      emit(CreateBookingSuccess(booking));
    } on BookingException catch (e) {
      emit(CreateBookingFailure(e.message, code: e.code));
    }
  }
}
