import 'package:frontend/features/payment/domain/entities/payment.dart';

/// Ánh xạ JSON `PublicPayment` / envelope tạo phiên của backend → entity.
abstract final class PaymentModel {
  static Payment fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] as String,
    bookingId: json['bookingId'] as String,
    method: PaymentMethod.fromApi(json['method'] as String?),
    status: PaymentStatus.fromApi(json['status'] as String?),
    amount: (json['amount'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    gatewayRef: json['gatewayRef'] as String?,
    paidAt: json['paidAt'] == null
        ? null
        : DateTime.parse(json['paidAt'] as String),
  );

  /// Envelope `{ payment, payUrl }` của `POST /api/payments`.
  static PaymentSession sessionFromJson(Map<String, dynamic> json) =>
      PaymentSession(
        payment: fromJson(json['payment'] as Map<String, dynamic>),
        payUrl: json['payUrl'] as String,
        provider: json['provider'] as String? ?? 'mock',
      );
}
