import 'package:frontend/features/review/data/datasources/review_remote_datasource.dart';
import 'package:frontend/features/review/data/models/review_model.dart';
import 'package:frontend/features/review/domain/entities/review.dart';
import 'package:frontend/features/review/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  const ReviewRepositoryImpl(this._remote);

  final ReviewRemoteDataSource _remote;

  @override
  Future<Review> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async => ReviewModel.fromJson(
    await _remote.create(
      bookingId: bookingId,
      rating: rating,
      comment: comment,
    ),
  );

  @override
  Future<ReviewSummary> listForUser(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async => ReviewModel.summaryFromJson(
    await _remote.listForUser(userId, page: page, limit: limit),
  );
}
