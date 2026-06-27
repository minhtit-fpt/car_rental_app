import 'package:frontend/features/community/domain/entities/trip_story.dart';
import 'package:frontend/features/community/domain/repositories/community_repository.dart';

/// Lấy feed câu chuyện chuyến đi (`GET /api/community`).
class ListStoriesUseCase {
  const ListStoriesUseCase(this._repository);

  final CommunityRepository _repository;

  Future<List<TripStory>> call({int page = 1, int limit = 20}) =>
      _repository.list(page: page, limit: limit);
}
