import 'package:equatable/equatable.dart';

/// Trạng thái thanh toán — khớp enum backend.
enum PaymentStatus { pending, paid, failed, refunded }

PaymentStatus paymentStatusFromWire(String? value) => switch (value) {
      'PAID' => PaymentStatus.paid,
      'FAILED' => PaymentStatus.failed,
      'REFUNDED' => PaymentStatus.refunded,
      _ => PaymentStatus.pending,
    };

/// Phiên thanh toán trả về khi tạo (POST /api/payments).
class PaymentSession extends Equatable {
  const PaymentSession({
    required this.paymentId,
    required this.payUrl,
    required this.status,
  });

  final String paymentId;
  final String payUrl;
  final PaymentStatus status;

  @override
  List<Object?> get props => [paymentId, payUrl, status];
}
