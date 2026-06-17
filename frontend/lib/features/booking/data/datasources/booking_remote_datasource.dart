import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint `/api/bookings*` (đều cần xác thực).
class BookingRemoteDataSource {
  const BookingRemoteDataSource(this._client);

  final ApiClient _client;

  /// `POST /api/bookings` — tạo đơn. Thời gian gửi dạng ISO 8601 UTC (hậu tố `Z`)
  /// để khớp validator `datetime({ offset: true })` của backend.
  Future<Map<String, dynamic>> create({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
    required bool deliveryRequested,
  }) async {
    final data = await _client.post(
      '/api/bookings',
      data: {
        'vehicleId': vehicleId,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'deliveryRequested': deliveryRequested,
      },
    );
    return data as Map<String, dynamic>;
  }

  /// `GET /api/bookings` — trả phần `items` của envelope phân trang.
  Future<List<dynamic>> list({String? status, int page = 1, int limit = 20}) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      'status': ?status,
    };
    final data = await _client.get('/api/bookings', query: query);
    return (data as Map<String, dynamic>)['items'] as List<dynamic>;
  }

  /// `GET /api/bookings/:id` — chi tiết một đơn.
  Future<Map<String, dynamic>> getById(String id) async {
    final data = await _client.get('/api/bookings/$id');
    return data as Map<String, dynamic>;
  }

  /// `POST /api/bookings/:id/cancel` — huỷ đơn.
  Future<Map<String, dynamic>> cancel(String id) async {
    final data = await _client.post('/api/bookings/$id/cancel');
    return data as Map<String, dynamic>;
  }
}
