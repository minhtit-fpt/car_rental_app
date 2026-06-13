import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/booking/domain/entities/booking_state.dart';

export 'package:frontend/features/booking/domain/entities/booking_state.dart';

class BookingCubit extends Cubit<BookingFormState> {
  BookingCubit() : super(const BookingFormState());

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

  Future<void> confirmBooking() async {
    if (!state.datesSelected) return;
    emit(state.copyWith(isSubmitting: true));
    await Future.delayed(const Duration(milliseconds: 1200));
    emit(state.copyWith(isSubmitting: false, submitted: true));
  }
}
