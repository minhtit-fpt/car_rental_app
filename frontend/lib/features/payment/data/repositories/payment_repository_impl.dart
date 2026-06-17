import 'package:frontend/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:frontend/features/payment/data/models/payment_model.dart';
import 'package:frontend/features/payment/domain/entities/payment.dart';
import 'package:frontend/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl(this._remote);

  final PaymentRemoteDataSource _remote;

  @override
  Future<PaymentSession> createPayment(String bookingId) async =>
      PaymentModel.sessionFromJson(await _remote.create(bookingId));

  @override
  Future<Payment> getPayment(String id) async =>
      PaymentModel.fromJson(await _remote.getById(id));

  @override
  Future<Payment> confirmPayment(
    String id, {
    bool success = true,
    Map<String, String>? params,
  }) async => PaymentModel.fromJson(
    await _remote.confirm(id, success: success, params: params),
  );
}
