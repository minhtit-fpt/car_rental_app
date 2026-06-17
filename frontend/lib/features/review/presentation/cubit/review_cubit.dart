import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/review/domain/usecases/create_review_usecase.dart';
import 'package:frontend/features/review/presentation/cubit/review_state.dart';

export 'package:frontend/features/review/presentation/cubit/review_state.dart';

class ReviewCubit extends Cubit<ReviewSubmitState> {
  ReviewCubit({required CreateReviewUseCase createReview})
    : _createReview = createReview,
      super(const ReviewIdle());

  final CreateReviewUseCase _createReview;

  Future<void> submit({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    if (state is ReviewSubmitting) return;
    emit(const ReviewSubmitting());
    try {
      final review = await _createReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
      emit(ReviewSubmitted(review));
    } on ApiException catch (e) {
      emit(ReviewSubmitError(e.message));
    }
  }
}
