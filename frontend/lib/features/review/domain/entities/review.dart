/// Đánh giá giữa người thuê và chủ xe — phản chiếu `PublicReview` của backend.
class Review {
  const Review({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.targetId,
    required this.rating,
    required this.createdAt,
    this.comment,
  });

  final String id;
  final String bookingId;
  final String reviewerId;
  final String targetId;
  final int rating;
  final DateTime createdAt;
  final String? comment;
}

/// Danh sách đánh giá nhận được + điểm trung bình (`GET /api/users/:id/reviews`).
class ReviewSummary {
  const ReviewSummary({
    required this.items,
    required this.total,
    required this.average,
    required this.page,
    required this.limit,
  });

  final List<Review> items;
  final int total;
  final double average;
  final int page;
  final int limit;
}
