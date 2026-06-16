import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint `/api/admin/*` (đã chặn role ADMIN ở backend).
class AdminRemoteDataSource {
  const AdminRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> stats() async {
    final data = await _client.get('/api/admin/stats');
    return data as Map<String, dynamic>;
  }
}
