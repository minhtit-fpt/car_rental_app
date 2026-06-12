import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/payment/domain/entities/payment.dart';
import 'package:frontend/features/payment/domain/payment_exception.dart';
import 'package:frontend/features/payment/domain/usecases/confirm_payment_usecase.dart';
import 'package:frontend/features/payment/domain/usecases/create_payment_usecase.dart';
import 'package:frontend/features/payment/presentation/cubit/payment_state.dart';

class PaymentCubit extends Cubit<PaymentFlowState> {
  PaymentCubit({
    required CreatePaymentUseCase createPayment,
    required ConfirmPaymentUseCase confirmPayment,
  })  : _createPayment = createPayment,
        _confirmPayment = confirmPayment,
        super(const PaymentCreating());

  final CreatePaymentUseCase _createPayment;
  final ConfirmPaymentUseCase _confirmPayment;

  /// Tạo phiên thanh toán cho đơn. Gọi một lần khi mở màn hình.
  Future<void> start(String bookingId) async {
    emit(const PaymentCreating());
    try {
      final session = await _createPayment(bookingId);
      // Cổng có thể trả về đã PAID (idempotent) — coi như xong.
      if (session.status == PaymentStatus.paid) {
        emit(const PaymentPaid());
        return;
      }
      emit(PaymentReady(session));
    } on PaymentException catch (e) {
      emit(PaymentFlowFailure(e.message, code: e.code));
    }
  }

  /// Mô phỏng callback cổng. [success] = false để thử nhánh thất bại.
  Future<void> confirm({bool success = true}) async {
    final current = state;
    if (current is! PaymentReady || current.confirming) return;
    emit(PaymentReady(current.session, confirming: true));
    try {
      final status = await _confirmPayment(
        current.session.paymentId,
        success: success,
      );
      if (status == PaymentStatus.paid) {
        emit(const PaymentPaid());
      } else {
        emit(
          PaymentFlowFailure(
            'Thanh toán không thành công, vui lòng thử lại',
            session: current.session,
          ),
        );
      }
    } on PaymentException catch (e) {
      emit(
        PaymentFlowFailure(e.message, code: e.code, session: current.session),
      );
    }
  }

  /// Quay lại trạng thái sẵn sàng sau khi lỗi confirm (cho phép thử lại).
  void reset() {
    final current = state;
    if (current is PaymentFlowFailure && current.session != null) {
      emit(PaymentReady(current.session!));
    }
  }
}
