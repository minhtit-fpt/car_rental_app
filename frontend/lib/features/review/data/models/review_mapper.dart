import 'package:frontend/features/review/domain/entities/review.dart';

Review reviewFromJson(Map<String, dynamic> json) {
  return Review(
    id: json['id'] as String,
    bookingId: json['bookingId'] as String,
    reviewerId: json['reviewerId'] as String,
    targetId: json['targetId'] as String,
    rating: (json['rating'] as num).toInt(),
    comment: json['comment'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

UserReviews userReviewsFromJson(Map<String, dynamic> json) {
  final items = (json['items'] as List<dynamic>)
      .map((e) => reviewFromJson(e as Map<String, dynamic>))
      .toList();
  return UserReviews(
    items: items,
    average: (json['average'] as num?)?.toDouble() ?? 0,
    total: (json['total'] as num?)?.toInt() ?? items.length,
  );
}
