import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/features/review/domain/entities/review.dart';
import 'package:frontend/features/review/domain/repositories/review_repository.dart';
import 'package:frontend/features/review/domain/review_exception.dart';
import 'package:frontend/features/review/domain/usecases/create_review_usecase.dart';
import 'package:frontend/features/review/presentation/cubit/create_review_cubit.dart';
import 'package:frontend/features/review/presentation/cubit/create_review_state.dart';

class MockCreateReviewUseCase extends Mock implements CreateReviewUseCase {}

class FakeCreateReviewParams extends Fake implements CreateReviewParams {}

void main() {
  late MockCreateReviewUseCase createReview;

  final review = Review(
    id: 'rev-1',
    bookingId: 'book-1',
    reviewerId: 'renter-1',
    targetId: 'owner-1',
    rating: 5,
    comment: 'Tốt',
    createdAt: DateTime.utc(2026, 6, 1),
  );

  const params = CreateReviewParams(
    bookingId: 'book-1',
    rating: 5,
    comment: 'Tốt',
  );

  setUpAll(() => registerFallbackValue(FakeCreateReviewParams()));
  setUp(() => createReview = MockCreateReviewUseCase());

  CreateReviewCubit build() => CreateReviewCubit(createReview);

  blocTest<CreateReviewCubit, CreateReviewState>(
    'submit emits [submitting, success]',
    setUp: () =>
        when(() => createReview(any())).thenAnswer((_) async => review),
    build: build,
    act: (cubit) => cubit.submit(params),
    expect: () => [
      const CreateReviewSubmitting(),
      CreateReviewSuccess(review),
    ],
  );

  blocTest<CreateReviewCubit, CreateReviewState>(
    'submit emits [submitting, failure] on already-reviewed',
    setUp: () => when(() => createReview(any())).thenThrow(
      const ReviewException('Đã đánh giá', code: 'ALREADY_REVIEWED'),
    ),
    build: build,
    act: (cubit) => cubit.submit(params),
    expect: () => [
      const CreateReviewSubmitting(),
      const CreateReviewFailure('Đã đánh giá', code: 'ALREADY_REVIEWED'),
    ],
  );
}
