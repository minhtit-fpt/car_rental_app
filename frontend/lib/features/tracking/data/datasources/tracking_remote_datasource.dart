import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint `/api/tracking*`.
class TrackingRemoteDataSource {
  const TrackingRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /api/tracking/:vehicleId/latest?trail=N` — vị trí realtime.
  Future<Map<String, dynamic>> latest(String vehicleId, {int trail = 20}) async {
    final data = await _client.get(
      '/api/tracking/$vehicleId/latest',
      query: {'trail': trail},
    );
    return data as Map<String, dynamic>;
  }

  /// `GET /api/tracking/active` — mọi xe đang chạy (admin).
  Future<List<dynamic>> active() async {
    final data = await _client.get('/api/tracking/active');
    return data as List<dynamic>;
  }
}
