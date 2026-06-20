import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/review/domain/entities/review.dart';
import 'package:frontend/features/review/presentation/cubit/user_reviews_cubit.dart';
import 'package:frontend/shared/widgets/rating_stars.dart';
import 'package:frontend/shared/widgets/section_header.dart';

/// Khối "Đánh giá" của một người dùng (vd: chủ xe ở màn chi tiết xe).
/// Tự nạp qua [UserReviewsCubit] khi dựng. Luôn hiển thị section (kể cả khi
/// chưa có đánh giá / đang tải / lỗi) để người dùng luôn thấy mục đánh giá.
class UserReviewsSection extends StatelessWidget {
  const UserReviewsSection({
    super.key,
    required this.userId,
    this.userName,
    this.maxItems = 3,
  });

  final String userId;
  final String? userName;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserReviewsCubit>(
      create: (_) => sl<UserReviewsCubit>()..load(userId),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: BlocBuilder<UserReviewsCubit, UserReviewsState>(
          builder: (context, state) => switch (state) {
            UserReviewsLoading() => const _ReviewsShell(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
            UserReviewsError() => const _ReviewsShell(
              child: _EmptyText('Không tải được đánh giá. Thử lại sau.'),
            ),
            UserReviewsLoaded(:final summary) when summary.total == 0 =>
              const _ReviewsShell(child: _EmptyText('Chưa có đánh giá nào.')),
            UserReviewsLoaded(:final summary) => _ReviewsCard(
              summary: summary,
              maxItems: maxItems,
              userId: userId,
              userName: userName,
            ),
          },
        ),
      ),
    );
  }
}

/// Khung card "Đánh giá" dùng chung cho trạng thái tải / lỗi / rỗng.
class _ReviewsShell extends StatelessWidget {
  const _ReviewsShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
          const SectionHeader(title: 'Đánh giá'),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard({
    required this.summary,
    required this.maxItems,
    required this.userId,
    required this.userName,
  });

  final ReviewSummary summary;
  final int maxItems;
  final String userId;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    final shown = summary.items.take(maxItems).toList(growable: false);
    final hasMore = summary.total > shown.length;
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
          SectionHeader(
            title: 'Đánh giá',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.accent,
                  size: 18,
                ),
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
          ),
          const SizedBox(height: 4),
          for (final review in shown) _ReviewRow(review: review),
          if (hasMore) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.push('/reviews/$userId', extra: userName),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Xem tất cả ${summary.total} đánh giá',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
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
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.navySoft,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Người thuê',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RatingStars(rating: review.rating.toDouble(), size: 14),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 6),
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

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}
