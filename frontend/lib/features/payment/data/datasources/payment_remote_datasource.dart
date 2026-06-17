import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint `/api/payments*` (đều cần xác thực).
class PaymentRemoteDataSource {
  const PaymentRemoteDataSource(this._client);

  final ApiClient _client;

  /// `POST /api/payments` — trả envelope `{ payment, payUrl }`.
  Future<Map<String, dynamic>> create(String bookingId) async {
    final data = await _client.post(
      '/api/payments',
      data: {'bookingId': bookingId},
    );
    return data as Map<String, dynamic>;
  }

  /// `GET /api/payments/:id` — chi tiết giao dịch.
  Future<Map<String, dynamic>> getById(String id) async {
    final data = await _client.get('/api/payments/$id');
    return data as Map<String, dynamic>;
  }

  /// `POST /api/payments/:id/confirm` — trả envelope `{ payment, booking }`;
  /// lấy phần `payment`. Mock gửi `success`; VNPay thật gửi `params` (vnp_*).
  Future<Map<String, dynamic>> confirm(
    String id, {
    bool success = true,
    Map<String, String>? params,
  }) async {
    final data = await _client.post(
      '/api/payments/$id/confirm',
      data: {'success': success, 'params': ?params},
    );
    return (data as Map<String, dynamic>)['payment'] as Map<String, dynamic>;
  }
}
