import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/review/domain/repositories/review_repository.dart';
import 'package:frontend/features/review/domain/review_exception.dart';
import 'package:frontend/features/review/domain/usecases/create_review_usecase.dart';
import 'package:frontend/features/review/presentation/cubit/create_review_state.dart';

class CreateReviewCubit extends Cubit<CreateReviewState> {
  CreateReviewCubit(this._createReview) : super(const CreateReviewIdle());

  final CreateReviewUseCase _createReview;

  Future<void> submit(CreateReviewParams params) async {
    if (state is CreateReviewSubmitting) return;
    emit(const CreateReviewSubmitting());
    try {
      final review = await _createReview(params);
      emit(CreateReviewSuccess(review));
    } on ReviewException catch (e) {
      emit(CreateReviewFailure(e.message, code: e.code));
    }
  }
}
