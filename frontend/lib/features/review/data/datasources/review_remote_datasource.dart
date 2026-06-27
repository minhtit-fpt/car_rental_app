import 'package:frontend/core/network/api_client.dart';

/// Gọi các endpoint đánh giá (đều cần xác thực).
class ReviewRemoteDataSource {
  const ReviewRemoteDataSource(this._client);

  final ApiClient _client;

  /// `POST /api/reviews` — tạo đánh giá.
  Future<Map<String, dynamic>> create({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    final data = await _client.post(
      '/api/reviews',
      data: {'bookingId': bookingId, 'rating': rating, 'comment': ?comment},
    );
    return data as Map<String, dynamic>;
  }

  /// `GET /api/users/:id/reviews` — danh sách đánh giá + điểm trung bình.
  Future<Map<String, dynamic>> listForUser(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _client.get(
      '/api/users/$userId/reviews',
      query: {'page': page, 'limit': limit},
    );
    return data as Map<String, dynamic>;
  }
}
