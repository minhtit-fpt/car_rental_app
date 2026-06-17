import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint `/api/kyc/*`.
class KycRemoteDataSource {
  const KycRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /api/kyc/status` → trạng thái KYC hiện tại.
  Future<Map<String, dynamic>> status() async {
    final data = await _client.get('/api/kyc/status');
    return data as Map<String, dynamic>;
  }
}
