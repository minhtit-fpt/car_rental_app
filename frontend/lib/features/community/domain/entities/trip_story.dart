/// Một câu chuyện chuyến đi trên feed cộng đồng — phản chiếu `PublicStory`.
class TripStory {
  const TripStory({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.images,
    required this.likes,
    required this.createdAt,
    this.bookingId,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final List<String> images;
  final int likes;
  final DateTime createdAt;
  final String? bookingId;

  TripStory copyWith({int? likes}) => TripStory(
    id: id,
    authorId: authorId,
    authorName: authorName,
    content: content,
    images: images,
    likes: likes ?? this.likes,
    createdAt: createdAt,
    bookingId: bookingId,
  );
}
