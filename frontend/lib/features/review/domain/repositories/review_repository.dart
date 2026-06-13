import 'package:frontend/features/review/domain/entities/review.dart';

class CreateReviewParams {
  const CreateReviewParams({
    required this.bookingId,
    required this.rating,
    this.comment,
  });

  final String bookingId;
  final int rating;
  final String? comment;
}

abstract interface class ReviewRepository {
  Future<Review> create(CreateReviewParams params);

  Future<UserReviews> getForUser(String userId, {int page, int limit});
}
