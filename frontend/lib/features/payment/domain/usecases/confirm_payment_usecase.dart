import 'package:frontend/features/payment/domain/entities/payment.dart';
import 'package:frontend/features/payment/domain/repositories/payment_repository.dart';

class ConfirmPaymentUseCase {
  const ConfirmPaymentUseCase(this._repository);

  final PaymentRepository _repository;

  Future<PaymentStatus> call(String paymentId, {required bool success}) =>
      _repository.confirm(paymentId, success: success);
}
