import 'package:equatable/equatable.dart';
import 'package:frontend/features/review/domain/entities/review.dart';

sealed class CreateReviewState extends Equatable {
  const CreateReviewState();

  @override
  List<Object?> get props => [];
}

final class CreateReviewIdle extends CreateReviewState {
  const CreateReviewIdle();
}

final class CreateReviewSubmitting extends CreateReviewState {
  const CreateReviewSubmitting();
}

final class CreateReviewSuccess extends CreateReviewState {
  const CreateReviewSuccess(this.review);

  final Review review;

  @override
  List<Object?> get props => [review];
}

final class CreateReviewFailure extends CreateReviewState {
  const CreateReviewFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}
