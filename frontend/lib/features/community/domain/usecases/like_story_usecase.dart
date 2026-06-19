import 'package:frontend/features/community/domain/entities/trip_story.dart';
import 'package:frontend/features/community/domain/repositories/community_repository.dart';

/// Thích một câu chuyện (`POST /api/community/:id/like`).
class LikeStoryUseCase {
  const LikeStoryUseCase(this._repository);

  final CommunityRepository _repository;

  Future<TripStory> call(String id) => _repository.like(id);
}
