import 'package:frontend/features/review/domain/entities/review.dart';
import 'package:frontend/features/review/domain/repositories/review_repository.dart';

/// Lấy danh sách đánh giá nhận được của một người dùng + điểm trung bình
/// (`GET /api/users/:id/reviews`).
class ListUserReviewsUseCase {
  const ListUserReviewsUseCase(this._repository);

  final ReviewRepository _repository;

  Future<ReviewSummary> call(String userId, {int page = 1, int limit = 20}) =>
      _repository.listForUser(userId, page: page, limit: limit);
}
