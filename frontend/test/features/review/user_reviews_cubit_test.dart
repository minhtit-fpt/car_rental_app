import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/review/domain/entities/review.dart';
import 'package:frontend/features/review/domain/repositories/review_repository.dart';
import 'package:frontend/features/review/domain/usecases/list_user_reviews_usecase.dart';
import 'package:frontend/features/review/presentation/cubit/user_reviews_cubit.dart';

final _summary = ReviewSummary(
  items: [
    Review(
      id: 'r1',
      bookingId: 'b1',
      reviewerId: 'u2',
      targetId: 'owner1',
      rating: 5,
      createdAt: DateTime.utc(2026, 1, 1),
      comment: 'Xe sạch, chủ thân thiện',
    ),
  ],
  total: 1,
  average: 5,
  page: 1,
  limit: 20,
);

/// Fake cấu hình được — không chạm mạng.
class _FakeReviewRepository implements ReviewRepository {
  ReviewSummary? summaryResult;
  Object? listError;

  @override
  Future<Review> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) => throw UnimplementedError();

  @override
  Future<ReviewSummary> listForUser(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    if (listError != null) throw listError!;
    return summaryResult!;
  }
}

UserReviewsCubit _build(_FakeReviewRepository repo) =>
    UserReviewsCubit(listUserReviews: ListUserReviewsUseCase(repo));

void main() {
  group('UserReviewsCubit', () {
    late _FakeReviewRepository repo;

    setUp(() => repo = _FakeReviewRepository());

    test('starts in loading state', () {
      expect(_build(repo).state, isA<UserReviewsLoading>());
    });

    blocTest<UserReviewsCubit, UserReviewsState>(
      'load success emits loading then loaded with the summary',
      build: () {
        repo.summaryResult = _summary;
        return _build(repo);
      },
      act: (cubit) => cubit.load('owner1'),
      expect: () => [
        isA<UserReviewsLoading>(),
        isA<UserReviewsLoaded>()
            .having((s) => s.summary.total, 'total', 1)
            .having((s) => s.summary.average, 'average', 5),
      ],
    );

    blocTest<UserReviewsCubit, UserReviewsState>(
      'load failure surfaces the API error message',
      build: () {
        repo.listError = const ApiException(
          'Không tải được đánh giá',
          code: 'SERVER_ERROR',
        );
        return _build(repo);
      },
      act: (cubit) => cubit.load('owner1'),
      expect: () => [
        isA<UserReviewsLoading>(),
        isA<UserReviewsError>()
            .having((s) => s.message, 'message', 'Không tải được đánh giá'),
      ],
    );
  });
}
