import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint cộng đồng (TripStory) — đều cần xác thực.
class CommunityRemoteDataSource {
  const CommunityRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /api/community` — feed câu chuyện chuyến đi.
  Future<Map<String, dynamic>> list({int page = 1, int limit = 20}) async {
    final data = await _client.get(
      '/api/community',
      query: {'page': page, 'limit': limit},
    );
    return data as Map<String, dynamic>;
  }

  /// `POST /api/community` — đăng câu chuyện.
  Future<Map<String, dynamic>> create({
    required String content,
    List<String> images = const [],
  }) async {
    final data = await _client.post(
      '/api/community',
      data: {'content': content, 'images': images},
    );
    return data as Map<String, dynamic>;
  }

  /// `POST /api/community/:id/like` — tăng lượt thích.
  Future<Map<String, dynamic>> like(String id) async {
    final data = await _client.post('/api/community/$id/like');
    return data as Map<String, dynamic>;
  }
}
