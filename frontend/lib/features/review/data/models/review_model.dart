import 'package:frontend/features/review/domain/entities/review.dart';

/// Ánh xạ JSON `PublicReview` / `ReviewListResult` của backend → entity.
abstract final class ReviewModel {
  static Review fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] as String,
    bookingId: json['bookingId'] as String,
    reviewerId: json['reviewerId'] as String,
    targetId: json['targetId'] as String,
    rating: json['rating'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    comment: json['comment'] as String?,
  );

  static ReviewSummary summaryFromJson(Map<String, dynamic> json) =>
      ReviewSummary(
        items: (json['items'] as List<dynamic>)
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        total: json['total'] as int,
        average: (json['average'] as num).toDouble(),
        page: json['page'] as int,
        limit: json['limit'] as int,
      );
}
