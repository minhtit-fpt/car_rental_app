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
    bool? mine,
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
      'mine': ?(mine == true ? 'true' : null),
    };
    final data = await _client.get('/api/vehicles', query: query);
    return (data as Map<String, dynamic>)['items'] as List<dynamic>;
  }

  /// `GET /api/vehicles/:id/availability` — lịch bận (các đơn chiếm chỗ).
  Future<Map<String, dynamic>> availability(String id) async {
    final data = await _client.get('/api/vehicles/$id/availability');
    return data as Map<String, dynamic>;
  }

  /// `GET /api/vehicles/:id` — chi tiết một xe.
  Future<Map<String, dynamic>> getById(String id) async {
    final data = await _client.get('/api/vehicles/$id');
    return data as Map<String, dynamic>;
  }

  /// `GET /api/vehicles/:id/price-quote` — báo giá động (breakdown surge).
  /// Thời gian gửi ISO 8601 UTC (hậu tố `Z`) khớp validator backend.
  Future<Map<String, dynamic>> priceQuote(
    String id, {
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final data = await _client.get(
      '/api/vehicles/$id/price-quote',
      query: {
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
      },
    );
    return data as Map<String, dynamic>;
  }

  /// `POST /api/vehicles` — chủ xe đăng xe mới (cần role OWNER). Trả về xe vừa tạo.
  Future<Map<String, dynamic>> create({
    required String type,
    required String title,
    required double pricePerHour,
    required bool isElectric,
    required bool deliveryAvailable,
    required double lat,
    required double lng,
    int? seats,
    int? doors,
    String? transmission,
    String? city,
  }) async {
    final data = await _client.post(
      '/api/vehicles',
      data: {
        'type': type,
        'title': title,
        'pricePerHour': pricePerHour,
        'isElectric': isElectric,
        'deliveryAvailable': deliveryAvailable,
        'seats': ?seats,
        'doors': ?doors,
        'transmission': ?transmission,
        'city': ?city,
        'lat': lat,
        'lng': lng,
      },
    );
    return data as Map<String, dynamic>;
  }

  /// `PATCH /api/vehicles/:id` — chủ xe cập nhật xe (cần role OWNER, sở hữu xe).
  /// Chỉ gửi các trường khác null. `type` không cho phép đổi theo schema backend.
  Future<Map<String, dynamic>> update(
    String id, {
    String? title,
    double? pricePerHour,
    bool? isElectric,
    bool? deliveryAvailable,
    bool? isAvailable,
    int? seats,
    int? doors,
    String? transmission,
    String? city,
    double? lat,
    double? lng,
  }) async {
    final data = await _client.patch(
      '/api/vehicles/$id',
      data: {
        'title': ?title,
        'pricePerHour': ?pricePerHour,
        'isElectric': ?isElectric,
        'deliveryAvailable': ?deliveryAvailable,
        'isAvailable': ?isAvailable,
        'seats': ?seats,
        'doors': ?doors,
        'transmission': ?transmission,
        'city': ?city,
        'lat': ?lat,
        'lng': ?lng,
      },
    );
    return data as Map<String, dynamic>;
  }

  /// `DELETE /api/vehicles/:id` — chủ xe gỡ xe.
  Future<void> delete(String id) async {
    await _client.delete('/api/vehicles/$id');
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
