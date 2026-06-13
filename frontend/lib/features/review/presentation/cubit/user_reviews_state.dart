import 'package:equatable/equatable.dart';
import 'package:frontend/features/review/domain/entities/review.dart';

sealed class UserReviewsState extends Equatable {
  const UserReviewsState();

  @override
  List<Object?> get props => [];
}

final class UserReviewsLoading extends UserReviewsState {
  const UserReviewsLoading();
}

final class UserReviewsLoaded extends UserReviewsState {
  const UserReviewsLoaded(this.reviews);

  final UserReviews reviews;

  @override
  List<Object?> get props => [reviews];
}

final class UserReviewsError extends UserReviewsState {
  const UserReviewsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
