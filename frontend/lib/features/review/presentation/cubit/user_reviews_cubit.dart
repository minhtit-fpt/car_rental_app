import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/review/domain/usecases/list_user_reviews_usecase.dart';
import 'package:frontend/features/review/presentation/cubit/user_reviews_state.dart';

export 'package:frontend/features/review/presentation/cubit/user_reviews_state.dart';

/// Nạp đánh giá nhận được của một người dùng (vd: chủ xe ở màn chi tiết xe).
class UserReviewsCubit extends Cubit<UserReviewsState> {
  UserReviewsCubit({required ListUserReviewsUseCase listUserReviews})
    : _listUserReviews = listUserReviews,
      super(const UserReviewsLoading());

  final ListUserReviewsUseCase _listUserReviews;

  Future<void> load(String userId) async {
    emit(const UserReviewsLoading());
    try {
      emit(UserReviewsLoaded(await _listUserReviews(userId)));
    } on ApiException catch (e) {
      emit(UserReviewsError(e.message));
    } catch (e) {
      // Bắt mọi lỗi còn lại (vd lỗi parse) để KHÔNG kẹt ở Loading âm thầm.
      emit(UserReviewsError('Lỗi tải đánh giá: $e'));
    }
  }
}
