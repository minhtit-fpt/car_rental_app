import 'package:equatable/equatable.dart';

/// Một đánh giá — khớp PublicReview từ backend.
class Review extends Equatable {
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
  final String? comment;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, bookingId, reviewerId, targetId, rating, comment, createdAt];
}

/// Danh sách đánh giá nhận được của một user + điểm trung bình.
class UserReviews extends Equatable {
  const UserReviews({
    required this.items,
    required this.average,
    required this.total,
  });

  final List<Review> items;
  final double average;
  final int total;

  @override
  List<Object?> get props => [items, average, total];
}
