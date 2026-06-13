import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/booking/domain/booking_exception.dart';
import 'package:frontend/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:frontend/features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'package:frontend/features/booking/presentation/cubit/my_trips_state.dart';

class MyTripsCubit extends Cubit<MyTripsState> {
  MyTripsCubit({
    required GetMyBookingsUseCase getMyBookings,
    required CancelBookingUseCase cancelBooking,
  })  : _getMyBookings = getMyBookings,
        _cancelBooking = cancelBooking,
        super(const MyTripsLoading());

  final GetMyBookingsUseCase _getMyBookings;
  final CancelBookingUseCase _cancelBooking;

  Future<void> load() async {
    emit(const MyTripsLoading());
    try {
      final items = await _getMyBookings();
      emit(MyTripsLoaded(items: items));
    } on BookingException catch (e) {
      emit(MyTripsError(e.message));
    }
  }

  Future<String?> cancel(String id) async {
    final current = state;
    if (current is! MyTripsLoaded || current.cancellingId != null) return null;
    emit(current.copyWith(cancellingId: id));
    try {
      final updated = await _cancelBooking(id);
      final items = current.items
          .map((b) => b.id == id ? updated : b)
          .toList(growable: false);
      emit(MyTripsLoaded(items: items));
      return null;
    } on BookingException catch (e) {
      emit(current.copyWith(clearCancelling: true));
      return e.message;
    }
  }
}
