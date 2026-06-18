import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:frontend/features/booking/domain/usecases/list_bookings_usecase.dart';
import 'package:frontend/features/booking/presentation/cubit/my_trips_state.dart';

export 'package:frontend/features/booking/presentation/cubit/my_trips_state.dart';

/// Danh sách chuyến (đơn đặt) của người dùng + huỷ đơn.
class MyTripsCubit extends Cubit<MyTripsState> {
  MyTripsCubit({
    required ListBookingsUseCase listBookings,
    required CancelBookingUseCase cancelBooking,
  }) : _listBookings = listBookings,
       _cancelBooking = cancelBooking,
       super(const MyTripsLoading());

  final ListBookingsUseCase _listBookings;
  final CancelBookingUseCase _cancelBooking;

  Future<void> load() async {
    emit(const MyTripsLoading());
    try {
      emit(MyTripsLoaded(await _listBookings()));
    } on ApiException catch (e) {
      emit(MyTripsError(e.message));
    }
  }

  Future<void> cancel(String id) async {
    final current = state;
    if (current is! MyTripsLoaded || current.cancellingId != null) return;
    emit(current.copyWith(cancellingId: id));
    try {
      final updated = await _cancelBooking(id);
      final next = current.bookings
          .map((b) => b.id == id ? updated : b)
          .toList(growable: false);
      emit(MyTripsLoaded(next));
    } on ApiException catch (e) {
      emit(MyTripsError(e.message));
    }
  }
}
