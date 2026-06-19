import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint thông báo (đều cần xác thực).
class NotificationRemoteDataSource {
  const NotificationRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /api/notifications` — danh sách + số chưa đọc.
  Future<Map<String, dynamic>> list({int page = 1, int limit = 20}) async {
    final data = await _client.get(
      '/api/notifications',
      query: {'page': page, 'limit': limit},
    );
    return data as Map<String, dynamic>;
  }

  /// `POST /api/notifications/:id/read` — đánh dấu đã đọc một thông báo.
  Future<Map<String, dynamic>> markRead(String id) async {
    final data = await _client.post('/api/notifications/$id/read');
    return data as Map<String, dynamic>;
  }

  /// `POST /api/notifications/read-all` — đánh dấu đã đọc tất cả.
  Future<void> markAllRead() => _client.post('/api/notifications/read-all');
}
