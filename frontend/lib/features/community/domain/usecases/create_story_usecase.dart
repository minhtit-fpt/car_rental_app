import 'package:frontend/features/community/domain/entities/trip_story.dart';
import 'package:frontend/features/community/domain/repositories/community_repository.dart';

/// Đăng một câu chuyện chuyến đi (`POST /api/community`).
class CreateStoryUseCase {
  const CreateStoryUseCase(this._repository);

  final CommunityRepository _repository;

  Future<TripStory> call({
    required String content,
    List<String> images = const [],
  }) => _repository.create(content: content, images: images);
}
