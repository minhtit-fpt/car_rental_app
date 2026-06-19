import 'package:frontend/features/community/domain/entities/trip_story.dart';

/// Hợp đồng domain cho cộng đồng (`/api/community`).
abstract interface class CommunityRepository {
  /// `GET /api/community` — feed câu chuyện chuyến đi.
  Future<List<TripStory>> list({int page, int limit});

  /// `POST /api/community` — đăng câu chuyện, trả về bài vừa tạo.
  Future<TripStory> create({required String content, List<String> images});

  /// `POST /api/community/:id/like` — thích, trả về bài đã cập nhật.
  Future<TripStory> like(String id);
}
