import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/features/review/domain/entities/review.dart';
import 'package:frontend/features/review/domain/review_exception.dart';
import 'package:frontend/features/review/domain/usecases/get_user_reviews_usecase.dart';
import 'package:frontend/features/review/presentation/cubit/user_reviews_cubit.dart';
import 'package:frontend/features/review/presentation/cubit/user_reviews_state.dart';

class MockGetUserReviewsUseCase extends Mock
    implements GetUserReviewsUseCase {}

void main() {
  late MockGetUserReviewsUseCase getUserReviews;

  final reviews = UserReviews(
    items: [
      Review(
        id: 'rev-1',
        bookingId: 'book-1',
        reviewerId: 'renter-1',
        targetId: 'owner-1',
        rating: 4,
        createdAt: DateTime.utc(2026, 6, 1),
      ),
    ],
    average: 4,
    total: 1,
  );

  setUp(() => getUserReviews = MockGetUserReviewsUseCase());

  UserReviewsCubit build() => UserReviewsCubit(getUserReviews);

  blocTest<UserReviewsCubit, UserReviewsState>(
    'load emits [loading, loaded]',
    setUp: () => when(
      () => getUserReviews('owner-1',
          page: any(named: 'page'), limit: any(named: 'limit')),
    ).thenAnswer((_) async => reviews),
    build: build,
    act: (cubit) => cubit.load('owner-1'),
    expect: () => [
      const UserReviewsLoading(),
      UserReviewsLoaded(reviews),
    ],
  );

  blocTest<UserReviewsCubit, UserReviewsState>(
    'load emits [loading, error] on failure',
    setUp: () => when(
      () => getUserReviews('owner-1',
          page: any(named: 'page'), limit: any(named: 'limit')),
    ).thenThrow(const ReviewException('boom')),
    build: build,
    act: (cubit) => cubit.load('owner-1'),
    expect: () => [
      const UserReviewsLoading(),
      const UserReviewsError('boom'),
    ],
  );
}
