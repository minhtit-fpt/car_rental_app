import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/section_header.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            const RvSliverAppBar(
              title: 'Điểm thưởng',
              subtitle: 'Tích lũy điểm cho mỗi chuyến đi',
              role: RvRole.renter,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const _PointsCard(),
                    const SizedBox(height: 20),
                    const _TierCard(),
                    const SizedBox(height: 20),
                    const _RewardsSection(),
                    const SizedBox(height: 20),
                    const _HistorySection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard();

  @override
  Widget build(BuildContext context) {
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
          const Text(
            '2,450',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'điểm thưởng',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(value: '12', label: 'Chuyến đi'),
                _Divider(),
                _MiniStat(value: '1.2M', label: 'Đã tiết kiệm'),
                _Divider(),
                _MiniStat(value: 'Gold', label: 'Hạng'),
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
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: Colors.white60)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 32, color: Colors.white.withAlpha(50));
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.warning.withAlpha(80)),
                ),
                child: const Text(
                  '🥇 Gold',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                '550 điểm nữa lên Platinum',
                style: TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.82,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.warning),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('2,450 / 3,000',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.mutedText)),
              Text('Platinum 🏆',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardsSection extends StatelessWidget {
  const _RewardsSection();

  @override
  Widget build(BuildContext context) {
    const rewards = [
      (emoji: '🎫', title: 'Giảm 10% chuyến đi', points: 200, desc: 'Hạn dùng: 30 ngày'),
      (emoji: '🛡️', title: 'Bảo hiểm miễn phí', points: 350, desc: 'Một chuyến đi'),
      (emoji: '🚗', title: 'Ưu tiên đặt xe', points: 500, desc: 'Trong 7 ngày'),
      (emoji: '💎', title: 'Nâng hạng ngay', points: 800, desc: 'Platinum 1 tháng'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Đổi điểm thưởng'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: rewards
              .map((r) => _RewardCard(
                    emoji: r.emoji,
                    title: r.title,
                    points: r.points,
                    desc: r.desc,
                    canRedeem: 2450 >= r.points,
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.emoji,
    required this.title,
    required this.points,
    required this.desc,
    required this.canRedeem,
  });

  final String emoji;
  final String title;
  final int points;
  final String desc;
  final bool canRedeem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: canRedeem
            ? AppColors.primary.withAlpha(13)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canRedeem
              ? AppColors.primary.withAlpha(60)
              : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: canRedeem
                      ? AppColors.primary
                      : AppColors.darkText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$points điểm',
                style: TextStyle(
                  fontSize: 11,
                  color: canRedeem
                      ? AppColors.primary
                      : AppColors.mutedText,
                  fontWeight: FontWeight.w500,
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
  const _HistorySection();

  @override
  Widget build(BuildContext context) {
    const history = [
      (title: 'Chuyến đi Tesla Model 3', delta: '+150', isEarn: true, time: 'Hôm nay'),
      (title: 'Đổi giảm 10% chuyến đi', delta: '-200', isEarn: false, time: 'Hôm qua'),
      (title: 'Đánh giá chuyến đi', delta: '+50', isEarn: true, time: '18/05'),
      (title: 'Chuyến đi BMW X5', delta: '+200', isEarn: true, time: '15/05'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Lịch sử điểm'),
        const SizedBox(height: 12),
        Container(
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
            children: history.asMap().entries.map((e) {
              final isLast = e.key == history.length - 1;
              final h = e.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                              Text(h.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.darkText,
                                  )),
                              Text(h.time,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.mutedText)),
                            ],
                          ),
                        ),
                        Text(
                          '${h.delta} điểm',
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
                    const Divider(
                        color: AppColors.border,
                        height: 1,
                        indent: 64),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
