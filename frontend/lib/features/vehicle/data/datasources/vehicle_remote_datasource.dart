import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint công khai `/api/vehicles*`.
class VehicleRemoteDataSource {
  const VehicleRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /api/vehicles` — trả phần `items` của envelope phân trang.
  /// Bool gửi dạng chuỗi "true"/"false" theo schema query của backend.
  Future<List<dynamic>> list({
    bool? isElectric,
    bool? available,
    num? minPrice,
    num? maxPrice,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      'isElectric': ?isElectric?.toString(),
      'available': ?available?.toString(),
      'minPrice': ?minPrice,
      'maxPrice': ?maxPrice,
    };
    final data = await _client.get('/api/vehicles', query: query);
    return (data as Map<String, dynamic>)['items'] as List<dynamic>;
  }

  /// `GET /api/vehicles/:id` — chi tiết một xe.
  Future<Map<String, dynamic>> getById(String id) async {
    final data = await _client.get('/api/vehicles/$id');
    return data as Map<String, dynamic>;
  }

  /// `GET /api/vehicles/nearby` — danh sách phẳng (không bọc `items`).
  Future<List<dynamic>> nearby({
    required double lat,
    required double lng,
    int radius = 5000,
    int limit = 20,
  }) async {
    final data = await _client.get(
      '/api/vehicles/nearby',
      query: {'lat': lat, 'lng': lng, 'radius': radius, 'limit': limit},
    );
    return data as List<dynamic>;
  }
}
