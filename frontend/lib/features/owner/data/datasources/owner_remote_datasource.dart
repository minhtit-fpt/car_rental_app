import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint chủ xe `/api/owner/*` và phê duyệt đơn (đều cần OWNER).
class OwnerRemoteDataSource {
  const OwnerRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /api/owner/bookings` — đơn đặt trên các xe của chủ xe (phần `items`).
  Future<List<dynamic>> listBookings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      'status': ?status,
    };
    final data = await _client.get('/api/owner/bookings', query: query);
    return (data as Map<String, dynamic>)['items'] as List<dynamic>;
  }

  /// `GET /api/owner/bookings/:id` — chi tiết 1 đơn (vd mở từ thông báo).
  Future<Map<String, dynamic>> getBookingById(String id) async {
    final data = await _client.get('/api/owner/bookings/$id');
    return data as Map<String, dynamic>;
  }

  /// `POST /api/bookings/:id/approve` — chấp nhận yêu cầu đặt.
  Future<Map<String, dynamic>> approve(String id) async {
    final data = await _client.post('/api/bookings/$id/approve');
    return data as Map<String, dynamic>;
  }

  /// `POST /api/bookings/:id/reject` — từ chối yêu cầu đặt.
  Future<Map<String, dynamic>> reject(String id) async {
    final data = await _client.post('/api/bookings/$id/reject');
    return data as Map<String, dynamic>;
  }

  /// `GET /api/owner/revenue` — tổng quan doanh thu.
  Future<Map<String, dynamic>> revenue({int months = 6}) async {
    final data = await _client.get(
      '/api/owner/revenue',
      query: {'months': months},
    );
    return data as Map<String, dynamic>;
  }
}
