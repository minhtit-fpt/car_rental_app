import 'package:frontend/features/review/data/datasources/review_remote_datasource.dart';
import 'package:frontend/features/review/domain/entities/review.dart';
import 'package:frontend/features/review/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  const ReviewRepositoryImpl(this._remote);

  final ReviewRemoteDataSource _remote;

  @override
  Future<Review> create(CreateReviewParams params) => _remote.create(params);

  @override
  Future<UserReviews> getForUser(String userId, {int page = 1, int limit = 20}) =>
      _remote.getForUser(userId, page: page, limit: limit);
}
