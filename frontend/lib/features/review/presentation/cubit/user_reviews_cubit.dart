import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/review/domain/review_exception.dart';
import 'package:frontend/features/review/domain/usecases/get_user_reviews_usecase.dart';
import 'package:frontend/features/review/presentation/cubit/user_reviews_state.dart';

class UserReviewsCubit extends Cubit<UserReviewsState> {
  UserReviewsCubit(this._getUserReviews) : super(const UserReviewsLoading());

  final GetUserReviewsUseCase _getUserReviews;

  Future<void> load(String userId) async {
    emit(const UserReviewsLoading());
    try {
      emit(UserReviewsLoaded(await _getUserReviews(userId)));
    } on ReviewException catch (e) {
      emit(UserReviewsError(e.message));
    }
  }
}
