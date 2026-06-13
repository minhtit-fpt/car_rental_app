import 'package:frontend/features/review/domain/entities/review.dart';
import 'package:frontend/features/review/domain/repositories/review_repository.dart';

class GetUserReviewsUseCase {
  const GetUserReviewsUseCase(this._repository);

  final ReviewRepository _repository;

  Future<UserReviews> call(String userId, {int page = 1, int limit = 20}) =>
      _repository.getForUser(userId, page: page, limit: limit);
}
