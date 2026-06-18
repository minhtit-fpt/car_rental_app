import 'package:frontend/features/review/domain/entities/review.dart';

sealed class UserReviewsState {
  const UserReviewsState();
}

final class UserReviewsLoading extends UserReviewsState {
  const UserReviewsLoading();
}

final class UserReviewsLoaded extends UserReviewsState {
  const UserReviewsLoaded(this.summary);
  final ReviewSummary summary;
}

final class UserReviewsError extends UserReviewsState {
  const UserReviewsError(this.message);
  final String message;
}
