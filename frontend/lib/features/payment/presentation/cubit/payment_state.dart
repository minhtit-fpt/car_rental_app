import 'package:equatable/equatable.dart';
import 'package:frontend/features/payment/domain/entities/payment.dart';

sealed class PaymentFlowState extends Equatable {
  const PaymentFlowState();

  @override
  List<Object?> get props => [];
}

/// Đang tạo phiên thanh toán (POST /api/payments).
final class PaymentCreating extends PaymentFlowState {
  const PaymentCreating();
}

/// Đã có payUrl — chờ người dùng xác nhận đã thanh toán (mock).
final class PaymentReady extends PaymentFlowState {
  const PaymentReady(this.session, {this.confirming = false});

  final PaymentSession session;
  final bool confirming;

  @override
  List<Object?> get props => [session, confirming];
}

/// Thanh toán thành công — đơn đã được xác nhận.
final class PaymentPaid extends PaymentFlowState {
  const PaymentPaid();
}

/// Lỗi tạo phiên hoặc xác nhận. [session] != null nếu lỗi xảy ra ở bước confirm.
final class PaymentFlowFailure extends PaymentFlowState {
  const PaymentFlowFailure(this.message, {this.session, this.code});

  final String message;
  final String? code;
  final PaymentSession? session;

  @override
  List<Object?> get props => [message, code, session];
}
