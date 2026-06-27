import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/loyalty/domain/entities/loyalty.dart';
import 'package:frontend/features/loyalty/presentation/cubit/loyalty_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/section_header.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoyaltyCubit>(
      create: (_) => sl<LoyaltyCubit>()..load(),
      child: const _LoyaltyView(),
    );
  }
}

class _LoyaltyView extends StatelessWidget {
  const _LoyaltyView();

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
              title: l10n.dashboardLoyaltyPoints,
              subtitle: l10n.loyaltySubtitle,
              role: RvRole.renter,
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<LoyaltyCubit, LoyaltyState>(
                builder: (context, state) => switch (state) {
                  LoyaltyLoading() => const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  LoyaltyError(:final message) => Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: _ErrorView(
                      message: message,
                      onRetry: () => context.read<LoyaltyCubit>().load(),
                    ),
                  ),
                  LoyaltyLoaded(:final summary) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _PointsCard(summary: summary),
                        const SizedBox(height: 20),
                        _TierCard(summary: summary),
                        const SizedBox(height: 20),
                        _HistorySection(history: summary.history),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.palette.secondaryText,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).commonRetry),
          ),
        ],
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.summary});
  final LoyaltySummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            '${summary.totalPoints}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            l10n.loyaltyPointsUnit,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MiniStat(value: summary.tier.label, label: l10n.loyaltyTier),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white60),
        ),
      ],
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.summary});
  final LoyaltySummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nextThreshold = summary.totalPoints + summary.pointsToNextTier;
    final progress = summary.nextTier == null || nextThreshold == 0
        ? 1.0
        : (summary.totalPoints / nextThreshold).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.warning.withAlpha(80)),
                ),
                child: Text(
                  '🥇 ${summary.tier.label}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
              const Spacer(),
              if (summary.nextTier != null)
                Text(
                  l10n.loyaltyPointsToNext(
                    summary.pointsToNextTier,
                    summary.nextTier!.label,
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.palette.mutedText,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.palette.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.warning,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${summary.totalPoints} / $nextThreshold',
                style: TextStyle(
                  fontSize: 12,
                  color: context.palette.mutedText,
                ),
              ),
              if (summary.nextTier != null)
                Text(
                  '${summary.nextTier!.label} 🏆',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.history});
  final List<LoyaltyEntry> history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.loyaltyHistory),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: context.palette.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.palette.border),
            ),
            child: Center(
              child: Text(
                l10n.loyaltyNoHistory,
                style: TextStyle(
                  fontSize: 13,
                  color: context.palette.mutedText,
                ),
              ),
            ),
          )
        else
          Container(
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
            child: Column(
              children: history.asMap().entries.map((e) {
                final isLast = e.key == history.length - 1;
                final h = e.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: h.isEarn
                                  ? AppColors.successSoft
                                  : AppColors.dangerSoft,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                h.isEarn
                                    ? Icons.add_rounded
                                    : Icons.remove_rounded,
                                size: 18,
                                color: h.isEarn
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.action,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: context.palette.darkText,
                                  ),
                                ),
                                Text(
                                  _shortDate(h.createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.palette.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${h.isEarn ? '+' : ''}'
                            '${l10n.loyaltyPointsShort(h.points)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: h.isEarn
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        color: context.palette.border,
                        height: 1,
                        indent: 64,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

String _shortDate(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inDays == 0) return 'Hôm nay';
  if (diff.inDays == 1) return 'Hôm qua';
  return '${time.day}/${time.month}';
}
