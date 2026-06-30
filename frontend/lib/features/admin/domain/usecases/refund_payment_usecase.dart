import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class RefundPaymentUseCase {
  const RefundPaymentUseCase(this._repository);

  final AdminRepository _repository;

  Future<void> call(String id, {required double amount, required String reason}) =>
      _repository.refundPayment(id, amount: amount, reason: reason);
}
