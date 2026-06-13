import 'package:frontend/features/review/domain/entities/review.dart';
import 'package:frontend/features/review/domain/repositories/review_repository.dart';

class CreateReviewUseCase {
  const CreateReviewUseCase(this._repository);

  final ReviewRepository _repository;

  Future<Review> call(CreateReviewParams params) => _repository.create(params);
}
