import 'package:dio/dio.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/features/payment/domain/entities/payment.dart';
import 'package:frontend/features/payment/domain/payment_exception.dart';

class PaymentRemoteDataSource {
  const PaymentRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaymentSession> create(String bookingId) async {
    try {
      final res = await _dio.post<dynamic>(
        PaymentEndpoints.list,
        data: {'bookingId': bookingId},
      );
      final data = _data(res) as Map<String, dynamic>;
      final payment = data['payment'] as Map<String, dynamic>;
      return PaymentSession(
        paymentId: payment['id'] as String,
        payUrl: data['payUrl'] as String,
        status: paymentStatusFromWire(payment['status'] as String?),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<PaymentStatus> confirm(
    String paymentId, {
    required bool success,
  }) async {
    try {
      final res = await _dio.post<dynamic>(
        PaymentEndpoints.confirm(paymentId),
        data: {'success': success},
      );
      final data = _data(res) as Map<String, dynamic>;
      final payment = data['payment'] as Map<String, dynamic>;
      return paymentStatusFromWire(payment['status'] as String?);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  dynamic _data(Response<dynamic> res) {
    final body = res.data as Map<String, dynamic>;
    return body['data'];
  }

  PaymentException _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return PaymentException(
        (data['error'] as String?) ?? 'Đã xảy ra lỗi',
        code: data['code'] as String?,
      );
    }
    return const PaymentException('Không thể kết nối tới máy chủ');
  }
}
