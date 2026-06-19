import 'package:frontend/features/community/domain/entities/trip_story.dart';

/// Ánh xạ JSON `PublicStory` / `StoryListResult` của backend → entity.
abstract final class TripStoryModel {
  static TripStory fromJson(Map<String, dynamic> json) => TripStory(
    id: json['id'] as String,
    authorId: json['authorId'] as String,
    authorName: json['authorName'] as String,
    content: json['content'] as String,
    images: (json['images'] as List<dynamic>)
        .map((e) => e as String)
        .toList(growable: false),
    likes: json['likes'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    bookingId: json['bookingId'] as String?,
  );

  static List<TripStory> listFromJson(Map<String, dynamic> json) =>
      (json['items'] as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
}
