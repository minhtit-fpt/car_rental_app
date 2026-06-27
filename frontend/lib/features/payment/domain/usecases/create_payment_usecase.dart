import 'package:frontend/features/payment/domain/entities/payment.dart';
import 'package:frontend/features/payment/domain/repositories/payment_repository.dart';

class CreatePaymentUseCase {
  const CreatePaymentUseCase(this._repository);

  final PaymentRepository _repository;

  Future<PaymentSession> call(String bookingId) =>
      _repository.createPayment(bookingId);
}
