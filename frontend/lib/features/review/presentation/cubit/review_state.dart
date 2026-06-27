import 'package:frontend/features/review/domain/entities/review.dart';

sealed class ReviewSubmitState {
  const ReviewSubmitState();
}

final class ReviewIdle extends ReviewSubmitState {
  const ReviewIdle();
}

final class ReviewSubmitting extends ReviewSubmitState {
  const ReviewSubmitting();
}

final class ReviewSubmitted extends ReviewSubmitState {
  const ReviewSubmitted(this.review);
  final Review review;
}

final class ReviewSubmitError extends ReviewSubmitState {
  const ReviewSubmitError(this.message);
  final String message;
}
