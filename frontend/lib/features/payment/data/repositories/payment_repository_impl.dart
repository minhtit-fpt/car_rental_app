import 'package:frontend/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:frontend/features/payment/domain/entities/payment.dart';
import 'package:frontend/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl(this._remote);

  final PaymentRemoteDataSource _remote;

  @override
  Future<PaymentSession> create(String bookingId) =>
      _remote.create(bookingId);

  @override
  Future<PaymentStatus> confirm(String paymentId, {required bool success}) =>
      _remote.confirm(paymentId, success: success);
}
