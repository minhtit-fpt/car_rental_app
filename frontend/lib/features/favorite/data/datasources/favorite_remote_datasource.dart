import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint xe yêu thích (đều cần xác thực).
class FavoriteRemoteDataSource {
  const FavoriteRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /api/favorites` — danh sách xe đã lưu (mảng PublicVehicle).
  Future<List<dynamic>> list() async {
    final data = await _client.get('/api/favorites');
    return data as List<dynamic>;
  }

  /// `POST /api/favorites/:vehicleId` — thêm xe vào yêu thích.
  Future<void> add(String vehicleId) async {
    await _client.post('/api/favorites/$vehicleId');
  }

  /// `DELETE /api/favorites/:vehicleId` — bỏ xe khỏi yêu thích.
  Future<void> remove(String vehicleId) async {
    await _client.delete('/api/favorites/$vehicleId');
  }
}
