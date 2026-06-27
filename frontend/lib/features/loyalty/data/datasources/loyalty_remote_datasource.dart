import 'package:frontend/core/network/api_client.dart';

/// Gọi endpoint điểm thưởng (cần xác thực).
class LoyaltyRemoteDataSource {
  const LoyaltyRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /api/loyalty` — tổng điểm + hạng + lịch sử.
  Future<Map<String, dynamic>> getSummary({
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _client.get(
      '/api/loyalty',
      query: {'page': page, 'limit': limit},
    );
    return data as Map<String, dynamic>;
  }
}
