import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/inspection/domain/entities/damage_report.dart';
import 'package:frontend/features/inspection/domain/repositories/inspection_repository.dart';
import 'package:frontend/features/inspection/presentation/cubit/inspection_cubit.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';

/// Màn kiểm tra xe + AI nhận diện hư hỏng: chụp ảnh nhận/trả xe rồi để VLM so
/// sánh và liệt kê hư hỏng mới kèm gợi ý bồi thường.
class VehicleInspectionScreen extends StatelessWidget {
  const VehicleInspectionScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InspectionCubit(
        bookingId: bookingId,
        repository: sl<InspectionRepository>(),
      )..loadExistingReport(),
      child: const _InspectionView(),
    );
  }
}

class _InspectionView extends StatelessWidget {
  const _InspectionView();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: BlocConsumer<InspectionCubit, InspectionState>(
          listenWhen: (a, b) =>
              b.errorMessage != null && a.errorMessage != b.errorMessage,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? '')),
            );
          },
          builder: (context, state) {
            final cubit = context.read<InspectionCubit>();
            return CustomScrollView(
              slivers: [
                const RvSliverAppBar(
                  title: 'Kiểm tra xe',
                  subtitle: 'AI nhận diện hư hỏng khi nhận / trả',
                  role: RvRole.renter,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        _PhaseCard(
                          icon: Icons.login_rounded,
                          title: 'Ảnh khi nhận xe',
                          hint: 'Chụp 4 góc + nội thất lúc nhận xe',
                          status: state.checkin,
                          count: state.checkinCount,
                          onPick: cubit.pickCheckinPhotos,
                        ),
                        const SizedBox(height: 16),
                        _PhaseCard(
                          icon: Icons.logout_rounded,
                          title: 'Ảnh khi trả xe',
                          hint: 'Chụp lại đúng các góc đó lúc trả xe',
                          status: state.checkout,
                          count: state.checkoutCount,
                          onPick: cubit.pickCheckoutPhotos,
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: state.isAnalyzing
                              ? 'Đang phân tích…'
                              : 'Phân tích hư hỏng (AI)',
                          icon: Icons.auto_awesome,
                          onPressed: state.canAnalyze ? cubit.analyze : null,
                        ),
                        if (!state.canAnalyze && state.report == null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Cần đủ ảnh nhận xe và trả xe trước khi phân tích.',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.palette.mutedText,
                            ),
                          ),
                        ],
                        if (state.report != null) ...[
                          const SizedBox(height: 20),
                          _ReportCard(report: state.report!),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({
    required this.icon,
    required this.title,
    required this.hint,
    required this.status,
    required this.count,
    required this.onPick,
  });

  final IconData icon;
  final String title;
  final String hint;
  final PhaseStatus status;
  final int count;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final working = status == PhaseStatus.working;
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.palette.darkText,
                  ),
                ),
              ),
              if (status == PhaseStatus.done)
                _DoneBadge(count: count)
              else if (working)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hint,
            style: TextStyle(fontSize: 13, color: context.palette.mutedText),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: working ? null : onPick,
            icon: const Icon(Icons.add_a_photo_outlined, size: 16),
            label: Text(status == PhaseStatus.done ? 'Chụp lại' : 'Chọn ảnh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneBadge extends StatelessWidget {
  const _DoneBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count ảnh ✓',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.success,
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});
  final DamageReport report;

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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔍', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Kết quả giám định AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.palette.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report.hasDamage
                ? report.summary
                : 'Không phát hiện hư hỏng mới. ${report.summary}'.trim(),
            style: TextStyle(
              fontSize: 14,
              color: context.palette.secondaryText,
              height: 1.4,
            ),
          ),
          if (report.hasDamage) ...[
            const SizedBox(height: 14),
            ...report.items.map((item) => _DamageRow(item: item)),
            const SizedBox(height: 8),
            Divider(color: context.palette.border, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gợi ý bồi thường',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.palette.mutedText,
                  ),
                ),
                Text(
                  _formatVnd(report.estimatedCost),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Mức bồi thường chỉ là gợi ý của AI, không thay thế thoả thuận giữa hai bên.',
              style: TextStyle(fontSize: 11, color: context.palette.mutedText),
            ),
          ],
        ],
      ),
    );
  }
}

class _DamageRow extends StatelessWidget {
  const _DamageRow({required this.item});
  final DamageItem item;

  @override
  Widget build(BuildContext context) {
    final (color, label) = _severityStyle(item.severity);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.palette.darkText,
                  ),
                ),
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.palette.secondaryText,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

(Color, String) _severityStyle(DamageSeverity severity) => switch (severity) {
  DamageSeverity.severe => (AppColors.danger, 'Nặng'),
  DamageSeverity.moderate => (AppColors.accent, 'Vừa'),
  DamageSeverity.minor => (AppColors.teal, 'Nhẹ'),
};

String _formatVnd(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '$buffer₫';
}
