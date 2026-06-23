import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/review/domain/entities/review.dart';
import 'package:frontend/features/review/presentation/cubit/user_reviews_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/rating_stars.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';

/// Màn "Xem tất cả" đánh giá nhận được của một người dùng (vd: chủ xe).
class UserReviewsScreen extends StatelessWidget {
  const UserReviewsScreen({super.key, required this.userId, this.userName});

  final String userId;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserReviewsCubit>(
      create: (_) => sl<UserReviewsCubit>()..load(userId),
      child: _UserReviewsView(userName: userName),
    );
  }
}

class _UserReviewsView extends StatelessWidget {
  const _UserReviewsView({this.userName});

  final String? userName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: CustomScrollView(
          slivers: [
            RvSliverAppBar(
              title: l10n.reviewsTitle,
              subtitle: userName != null && userName!.isNotEmpty
                  ? l10n.reviewsAboutUser(userName!)
                  : l10n.reviewsAllReceived,
            ),
            BlocBuilder<UserReviewsCubit, UserReviewsState>(
              builder: (context, state) => switch (state) {
                UserReviewsLoading() => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
                UserReviewsError(:final message) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: _Message(text: message),
                ),
                UserReviewsLoaded(:final summary) when summary.total == 0 =>
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _Message(text: l10n.reviewsEmpty),
                  ),
                UserReviewsLoaded(:final summary) => _ReviewsSliver(
                  summary: summary,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsSliver extends StatelessWidget {
  const _ReviewsSliver({required this.summary});

  final ReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList.separated(
        itemCount: summary.items.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) return _SummaryHeader(summary: summary);
          return _ReviewTile(review: summary.items[index - 1]);
        },
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.summary});

  final ReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            summary.average.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: context.palette.darkText,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RatingStars(rating: summary.average, size: 18),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).reviewsCount(summary.total),
                style: TextStyle(
                  fontSize: 13,
                  color: context.palette.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 6,
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
              RatingStars(rating: review.rating.toDouble(), size: 14),
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: context.palette.mutedText,
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 13,
                color: context.palette.secondaryText,
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

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: context.palette.secondaryText),
      ),
    );
  }
}
