import 'package:frontend/features/community/domain/entities/trip_story.dart';

sealed class CommunityState {
  const CommunityState();
}

final class CommunityLoading extends CommunityState {
  const CommunityLoading();
}

final class CommunityLoaded extends CommunityState {
  const CommunityLoaded(this.stories, {this.likedIds = const {}});
  final List<TripStory> stories;
  final Set<String> likedIds;

  CommunityLoaded copyWith({List<TripStory>? stories, Set<String>? likedIds}) =>
      CommunityLoaded(
        stories ?? this.stories,
        likedIds: likedIds ?? this.likedIds,
      );
}

final class CommunityError extends CommunityState {
  const CommunityError(this.message);
  final String message;
}
