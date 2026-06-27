import 'package:frontend/features/payment/domain/entities/payment.dart';
import 'package:frontend/features/payment/domain/repositories/payment_repository.dart';

class ConfirmPaymentUseCase {
  const ConfirmPaymentUseCase(this._repository);

  final PaymentRepository _repository;

  Future<Payment> call(
    String paymentId, {
    bool success = true,
    Map<String, String>? params,
  }) => _repository.confirmPayment(paymentId, success: success, params: params);
}
