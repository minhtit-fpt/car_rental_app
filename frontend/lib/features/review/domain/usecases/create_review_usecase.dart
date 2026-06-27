import 'package:frontend/features/review/domain/entities/review.dart';
import 'package:frontend/features/review/domain/repositories/review_repository.dart';

class CreateReviewUseCase {
  const CreateReviewUseCase(this._repository);

  final ReviewRepository _repository;

  Future<Review> call({
    required String bookingId,
    required int rating,
    String? comment,
  }) => _repository.createReview(
    bookingId: bookingId,
    rating: rating,
    comment: comment,
  );
}
