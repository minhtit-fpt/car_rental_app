import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/secondary_button.dart';
import 'package:frontend/shared/widgets/status_chip.dart';

const _months = [
  'Th1',
  'Th2',
  'Th3',
  'Th4',
  'Th5',
  'Th6',
  'Th7',
  'Th8',
  'Th9',
  'Th10',
  'Th11',
  'Th12',
];

String _fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

class ActiveTripScreen extends StatelessWidget {
  const ActiveTripScreen({
    super.key,
    required this.vehicle,
    required this.cubit,
  });

  final Vehicle vehicle;
  final BookingCubit cubit;

  @override
  Widget build(BuildContext context) {
    final state = cubit.state;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            const RvSliverAppBar(
              title: 'Chuyến đi đang diễn ra',
              subtitle: 'Quản lý chuyến đi của bạn',
              role: RvRole.renter,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _ActiveStatusCard(vehicle: vehicle, state: state),
                    const SizedBox(height: 16),
                    _TripProgressCard(state: state),
                    const SizedBox(height: 16),
                    _VehicleInfoCard(vehicle: vehicle),
                    const SizedBox(height: 16),
                    _QuickActionsRow(),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Trả xe',
                      onPressed: () => _showReturnDialog(context),
                      icon: Icons.check_circle_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: 'Hỗ trợ khẩn cấp',
                      onPressed: () {},
                      icon: Icons.emergency_rounded,
                    ),
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

  void _showReturnDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Xác nhận trả xe?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        content: const Text(
          'Bạn xác nhận đã trả xe và kết thúc chuyến đi này?',
          style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Chưa',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}

class _ActiveStatusCard extends StatelessWidget {
  const _ActiveStatusCard({required this.vehicle, required this.state});
  final Vehicle vehicle;
  final BookingFormState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(vehicle.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusChip(
                          label: '🟢 Đang chạy',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Nhận xe',
                  value: state.startDate != null
                      ? _fmtDate(state.startDate!)
                      : '—',
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withAlpha(50),
                ),
                _StatItem(
                  label: 'Trả xe',
                  value: state.endDate != null ? _fmtDate(state.endDate!) : '—',
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withAlpha(50),
                ),
                _StatItem(
                  label: 'Còn lại',
                  value: state.endDate != null
                      ? '${state.endDate!.difference(DateTime.now()).inDays.clamp(0, 365)} ngày'
                      : '—',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white60),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _TripProgressCard extends StatelessWidget {
  const _TripProgressCard({required this.state});
  final BookingFormState state;

  @override
  Widget build(BuildContext context) {
    final total = state.totalDays.clamp(1, 365);
    final elapsed = state.startDate != null
        ? DateTime.now().difference(state.startDate!).inDays.clamp(0, total)
        : 0;
    final progress = elapsed / total;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tiến trình chuyến đi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                '$elapsed/$total ngày',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.startDate != null ? _fmtDate(state.startDate!) : '—',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedText,
                ),
              ),
              Text(
                state.endDate != null ? _fmtDate(state.endDate!) : '—',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VehicleInfoCard extends StatelessWidget {
  const _VehicleInfoCard({required this.vehicle});
  final Vehicle vehicle;

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
            'Thông tin xe',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(icon: '🔑', label: 'Biển số: 30A-12345'),
              const SizedBox(width: 8),
              _InfoChip(
                icon: vehicle.isElectric ? '⚡' : '⛽',
                label: vehicle.isElectric ? 'Điện' : 'Xăng',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.ownerName ?? 'Chủ xe',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const Text(
                      'Chủ xe',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Gọi',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (icon: '🗺️', label: 'Bản đồ'),
      (icon: '💬', label: 'Nhắn tin'),
      (icon: '📸', label: 'Chụp ảnh'),
      (icon: '🚨', label: 'Báo hỏng'),
    ];

    return Row(
      children: actions
          .map(
            (a) => Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadowColor,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(a.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        a.label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
