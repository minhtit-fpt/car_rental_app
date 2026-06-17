import 'package:frontend/features/review/domain/entities/review.dart';

/// Hợp đồng domain cho đánh giá (`/api/reviews`, `/api/users/:id/reviews`).
abstract interface class ReviewRepository {
  /// `POST /api/reviews` — đánh giá đối tác trong một đơn. `rating` 1–5.
  Future<Review> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  });

  /// `GET /api/users/:id/reviews` — đánh giá nhận được + điểm trung bình.
  Future<ReviewSummary> listForUser(String userId, {int page, int limit});
}
