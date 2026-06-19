import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/owner/domain/entities/owner_booking.dart';
import 'package:frontend/features/owner/domain/usecases/approve_booking_usecase.dart';
import 'package:frontend/features/owner/domain/usecases/list_owner_bookings_usecase.dart';
import 'package:frontend/features/owner/domain/usecases/reject_booking_usecase.dart';
import 'package:frontend/features/owner/presentation/cubit/owner_bookings_state.dart';

export 'package:frontend/features/owner/presentation/cubit/owner_bookings_state.dart';

/// Danh sách đơn đặt trên các xe của chủ xe + chấp nhận/từ chối yêu cầu.
class OwnerBookingsCubit extends Cubit<OwnerBookingsState> {
  OwnerBookingsCubit({
    required ListOwnerBookingsUseCase listBookings,
    required ApproveBookingUseCase approveBooking,
    required RejectBookingUseCase rejectBooking,
  }) : _listBookings = listBookings,
       _approveBooking = approveBooking,
       _rejectBooking = rejectBooking,
       super(const OwnerBookingsLoading());

  final ListOwnerBookingsUseCase _listBookings;
  final ApproveBookingUseCase _approveBooking;
  final RejectBookingUseCase _rejectBooking;

  Future<void> load() async {
    emit(const OwnerBookingsLoading());
    try {
      emit(OwnerBookingsLoaded(await _listBookings()));
    } on ApiException catch (e) {
      emit(OwnerBookingsError(e.message));
    }
  }

  Future<void> approve(String id) => _act(id, _approveBooking.call);

  Future<void> reject(String id) => _act(id, _rejectBooking.call);

  Future<void> _act(
    String id,
    Future<OwnerBooking> Function(String) action,
  ) async {
    final current = state;
    if (current is! OwnerBookingsLoaded || current.actingId != null) return;
    emit(current.copyWith(actingId: id));
    try {
      final updated = await action(id);
      final next = current.bookings
          .map((b) => b.id == id ? updated : b)
          .toList(growable: false);
      emit(OwnerBookingsLoaded(next));
    } on ApiException catch (e) {
      emit(OwnerBookingsError(e.message));
    }
  }
}
