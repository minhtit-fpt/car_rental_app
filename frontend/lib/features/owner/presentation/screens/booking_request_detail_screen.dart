import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/secondary_button.dart';
import 'package:frontend/shared/widgets/status_chip.dart';

class BookingRequestDetailScreen extends StatelessWidget {
  const BookingRequestDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            const RvSliverAppBar(
              title: 'Chi tiết yêu cầu',
              subtitle: 'Xem xét và xử lý yêu cầu thuê xe',
              role: RvRole.owner,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _RenterCard(),
                    const SizedBox(height: 16),
                    _TripCard(),
                    const SizedBox(height: 16),
                    _VehicleCard(),
                    const SizedBox(height: 16),
                    _EarningsCard(),
                    const SizedBox(height: 20),
                    _ActionButtons(),
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

class _RenterCard extends StatelessWidget {
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thanh Nguyễn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Text('⭐',
                            style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 3),
                        const Text(
                          '4.8 · 8 chuyến · KYC ✅',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.mutedText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.message_outlined,
                    size: 14, color: AppColors.primary),
                label: const Text(
                  'Nhắn tin',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              StatusChip(
                  label: '🟡 Chờ xác nhận',
                  color: const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              const Text(
                'Yêu cầu lúc 14:32 hôm nay',
                style: TextStyle(
                    fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
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
          const Text(
            'Chi tiết chuyến đi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 14),
          _Row(icon: Icons.calendar_today_rounded,
              label: 'Nhận xe', value: '05 Th6 2025'),
          const SizedBox(height: 10),
          _Row(icon: Icons.event_rounded,
              label: 'Trả xe', value: '08 Th6 2025'),
          const SizedBox(height: 10),
          _Row(icon: Icons.schedule_rounded,
              label: 'Thời gian', value: '3 ngày'),
          const SizedBox(height: 10),
          _Row(icon: Icons.local_shipping_outlined,
              label: 'Giao xe', value: '123 Lê Lợi, Q1'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.mutedText)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText)),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.cardImageGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🚗', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tesla Model 3',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '2024 · Sedan · Điện · 30A-12345',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Column(
        children: [
          _EarnLine(label: '890K × 3 ngày', value: '2,670K'),
          const SizedBox(height: 8),
          _EarnLine(label: 'Phí nền tảng (10%)', value: '-267K'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.primary, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bạn nhận được',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const Text(
                '2,403K VNĐ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarnLine extends StatelessWidget {
  const _EarnLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.secondaryText)),
        Text('$value VNĐ',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText)),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          label: 'Chấp nhận yêu cầu',
          onPressed: () => context.pop(),
          icon: Icons.check_circle_outline_rounded,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Từ chối',
          onPressed: () => context.pop(),
          icon: Icons.cancel_outlined,
        ),
      ],
    );
  }
}
