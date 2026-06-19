import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/review/domain/entities/review.dart';
import 'package:frontend/features/review/presentation/cubit/user_reviews_cubit.dart';
import 'package:frontend/shared/widgets/rating_stars.dart';
import 'package:frontend/shared/widgets/section_header.dart';

/// Khối "Đánh giá" của một người dùng (vd: chủ xe ở màn chi tiết xe).
/// Tự nạp qua [UserReviewsCubit] khi dựng; ẩn hẳn nếu chưa có đánh giá nào.
class UserReviewsSection extends StatelessWidget {
  const UserReviewsSection({super.key, required this.userId, this.maxItems = 3});

  final String userId;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserReviewsCubit>(
      create: (_) => sl<UserReviewsCubit>()..load(userId),
      child: BlocBuilder<UserReviewsCubit, UserReviewsState>(
        builder: (context, state) => switch (state) {
          UserReviewsLoading() => const SizedBox.shrink(),
          UserReviewsError() => const SizedBox.shrink(),
          UserReviewsLoaded(:final summary) when summary.total == 0 =>
            const SizedBox.shrink(),
          UserReviewsLoaded(:final summary) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _ReviewsCard(summary: summary, maxItems: maxItems),
          ),
        },
      ),
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard({required this.summary, required this.maxItems});

  final ReviewSummary summary;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final shown = summary.items.take(maxItems).toList(growable: false);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeader(title: 'Đánh giá'),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.accent, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${summary.average.toStringAsFixed(1)} · ${summary.total}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final review in shown) _ReviewRow(review: review),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RatingStars(rating: review.rating.toDouble(), size: 14),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
