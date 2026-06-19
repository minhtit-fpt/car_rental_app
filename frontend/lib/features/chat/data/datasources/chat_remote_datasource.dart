import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint chat (đều cần xác thực).
class ChatRemoteDataSource {
  const ChatRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /api/conversations` — danh sách hội thoại.
  Future<List<dynamic>> listConversations() async {
    final data = await _client.get('/api/conversations');
    return data as List<dynamic>;
  }

  /// `POST /api/conversations` — tạo/lấy hội thoại theo booking hoặc người dùng.
  Future<Map<String, dynamic>> createConversation({
    String? participantId,
    String? bookingId,
  }) async {
    final data = await _client.post(
      '/api/conversations',
      data: {
        'participantId': ?participantId,
        'bookingId': ?bookingId,
      },
    );
    return data as Map<String, dynamic>;
  }

  /// `GET /api/conversations/:id/messages` — tin nhắn trong hội thoại.
  Future<Map<String, dynamic>> listMessages(
    String conversationId, {
    int page = 1,
    int limit = 30,
  }) async {
    final data = await _client.get(
      '/api/conversations/$conversationId/messages',
      query: {'page': page, 'limit': limit},
    );
    return data as Map<String, dynamic>;
  }

  /// `POST /api/conversations/:id/messages` — gửi tin nhắn.
  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String body,
  ) async {
    final data = await _client.post(
      '/api/conversations/$conversationId/messages',
      data: {'body': body},
    );
    return data as Map<String, dynamic>;
  }
}
