import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/get_admin_booking_detail_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/refund_payment_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_booking_detail_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_booking_detail_state.dart';

/// Chi tiết một đơn + thao tác hoàn tiền (TIỀN → cần admin confirm ở UI).
class AdminBookingDetailCubit extends Cubit<AdminBookingDetailState> {
  AdminBookingDetailCubit({
    required String bookingId,
    required GetAdminBookingDetailUseCase getDetail,
    required RefundPaymentUseCase refundPayment,
  }) : _bookingId = bookingId,
       _getDetail = getDetail,
       _refundPayment = refundPayment,
       super(const AdminBookingDetailLoading());

  final String _bookingId;
  final GetAdminBookingDetailUseCase _getDetail;
  final RefundPaymentUseCase _refundPayment;

  Future<void> load() async {
    emit(const AdminBookingDetailLoading());
    try {
      emit(AdminBookingDetailLoaded(await _getDetail(_bookingId)));
    } on ApiException catch (e) {
      emit(AdminBookingDetailError(e.message));
    }
  }

  /// Hoàn tiền `amount` với lý do `reason`, rồi tải lại chi tiết để phản ánh
  /// trạng thái REFUNDED mới.
  Future<void> refund({required double amount, required String reason}) async {
    final current = state;
    if (current is! AdminBookingDetailLoaded || current.submitting) return;
    emit(current.copyWith(submitting: true, refundError: null));
    try {
      await _refundPayment(_bookingId, amount: amount, reason: reason);
      final fresh = await _getDetail(_bookingId);
      emit(AdminBookingDetailLoaded(fresh, refunded: true));
    } on ApiException catch (e) {
      emit(current.copyWith(submitting: false, refundError: e.message));
    }
  }
}
