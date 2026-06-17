import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/payment/domain/entities/payment.dart';
import 'package:frontend/features/payment/domain/usecases/confirm_payment_usecase.dart';
import 'package:frontend/features/payment/domain/usecases/create_payment_usecase.dart';
import 'package:frontend/features/payment/presentation/cubit/payment_state.dart';

export 'package:frontend/features/payment/presentation/cubit/payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit({
    required CreatePaymentUseCase createPayment,
    required ConfirmPaymentUseCase confirmPayment,
  }) : _createPayment = createPayment,
       _confirmPayment = confirmPayment,
       super(const PaymentIdle());

  final CreatePaymentUseCase _createPayment;
  final ConfirmPaymentUseCase _confirmPayment;

  /// Tạo phiên thanh toán. Mock → tự xác nhận ngay. VNPay thật → phát
  /// [PaymentAwaitingGateway] để màn hình mở WebView cổng.
  Future<void> pay({required String bookingId}) async {
    if (state is PaymentProcessing) return;
    emit(const PaymentProcessing());
    try {
      final session = await _createPayment(bookingId);
      if (session.isMockGateway) {
        await _finalize(_confirmPayment(session.payment.id));
        return;
      }
      emit(
        PaymentAwaitingGateway(
          paymentId: session.payment.id,
          payUrl: session.payUrl,
        ),
      );
    } on ApiException catch (e) {
      emit(PaymentFailure(e.message));
    }
  }

  /// Sau khi WebView bắt được URL return của VNPay → gửi `params` (vnp_*) lên
  /// backend để xác thực chữ ký và chốt giao dịch.
  Future<void> confirmGateway({
    required String paymentId,
    required Map<String, String> params,
  }) async {
    emit(const PaymentProcessing());
    try {
      await _finalize(_confirmPayment(paymentId, params: params));
    } on ApiException catch (e) {
      emit(PaymentFailure(e.message));
    }
  }

  /// Người dùng đóng WebView trước khi hoàn tất.
  void cancelGateway() {
    emit(const PaymentFailure('Bạn đã huỷ thanh toán'));
  }

  Future<void> _finalize(Future<Payment> pending) async {
    final payment = await pending;
    if (payment.status.isPaid) {
      emit(PaymentSuccess(payment));
    } else {
      emit(const PaymentFailure('Giao dịch bị cổng thanh toán từ chối'));
    }
  }
}
