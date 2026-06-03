import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/secondary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';

enum KycStatus { pending, approved, rejected }

class KycStatusScreen extends StatelessWidget {
  const KycStatusScreen({super.key, this.status = KycStatus.pending});

  final KycStatus status;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            const RvSliverAppBar(
              title: 'Trạng thái KYC',
              subtitle: 'Xác minh danh tính của bạn',
              role: RvRole.neutral,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _StatusCard(status: status),
                    const SizedBox(height: 20),
                    _TimelineCard(status: status),
                    const SizedBox(height: 20),
                    if (status == KycStatus.rejected) ...[
                      _RejectionReasonCard(),
                      const SizedBox(height: 20),
                    ],
                    _ActionButtons(status: status),
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});
  final KycStatus status;

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo(status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: info.color.withAlpha(60)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: info.color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(info.emoji, style: const TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            info.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: info.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            info.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  ({String emoji, String title, String subtitle, Color color}) _statusInfo(
      KycStatus s) {
    return switch (s) {
      KycStatus.pending => (
          emoji: '⏳',
          title: 'Đang chờ xét duyệt',
          subtitle:
              'Hồ sơ của bạn đang được xem xét.\nThường mất 1–2 ngày làm việc.',
          color: AppColors.warning,
        ),
      KycStatus.approved => (
          emoji: '✅',
          title: 'Đã xác minh',
          subtitle: 'Tài khoản của bạn đã được xác minh.\nBạn có thể thuê xe ngay.',
          color: AppColors.success,
        ),
      KycStatus.rejected => (
          emoji: '❌',
          title: 'Xác minh thất bại',
          subtitle: 'Hồ sơ bị từ chối. Vui lòng\nnộp lại với ảnh rõ ràng hơn.',
          color: AppColors.danger,
        ),
    };
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.status});
  final KycStatus status;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep(
        label: 'Nộp hồ sơ',
        time: 'Hôm nay, 14:32',
        isDone: true,
      ),
      _TimelineStep(
        label: 'Đang xét duyệt',
        time: status == KycStatus.pending ? 'Đang xử lý...' : 'Hôm nay, 16:00',
        isDone: status != KycStatus.pending,
        isActive: status == KycStatus.pending,
      ),
      _TimelineStep(
        label: status == KycStatus.rejected ? 'Từ chối' : 'Xác minh hoàn tất',
        time: status == KycStatus.approved
            ? 'Hôm nay, 16:05'
            : status == KycStatus.rejected
                ? 'Hôm nay, 16:05'
                : 'Chờ xử lý',
        isDone: status == KycStatus.approved || status == KycStatus.rejected,
        isRejected: status == KycStatus.rejected,
      ),
    ];

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
          const Text(
            'Tiến trình xét duyệt',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((e) {
            final isLast = e.key == steps.length - 1;
            return _TimelineRow(step: e.value, isLast: isLast);
          }),
        ],
      ),
    );
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.label,
    required this.time,
    this.isDone = false,
    this.isActive = false,
    this.isRejected = false,
  });
  final String label;
  final String time;
  final bool isDone;
  final bool isActive;
  final bool isRejected;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step, required this.isLast});
  final _TimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dotColor = step.isRejected
        ? AppColors.danger
        : step.isDone
            ? AppColors.success
            : step.isActive
                ? AppColors.warning
                : AppColors.border;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: step.isDone || step.isActive || step.isRejected
                    ? dotColor.withAlpha(26)
                    : AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: dotColor, width: 2),
              ),
              child: step.isDone
                  ? Icon(
                      step.isRejected ? Icons.close : Icons.check,
                      size: 11,
                      color: dotColor,
                    )
                  : step.isActive
                      ? Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: step.isDone ? AppColors.success.withAlpha(60) : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: step.isDone || step.isActive
                        ? AppColors.darkText
                        : AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RejectionReasonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withAlpha(13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withAlpha(60)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.danger),
              SizedBox(width: 8),
              Text(
                'Lý do từ chối',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Ảnh CCCD bị mờ, không đọc được thông tin\n'
            '• Ảnh selfie không khớp với ảnh trên CCCD',
            style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.status});
  final KycStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      KycStatus.pending => SecondaryButton(
          label: 'Về trang chủ',
          onPressed: () => context.go('/'),
          icon: Icons.home_outlined,
        ),
      KycStatus.approved => PrimaryButton(
          label: 'Tìm xe ngay',
          onPressed: () => context.go('/'),
          icon: Icons.directions_car_rounded,
        ),
      KycStatus.rejected => Column(
          children: [
            PrimaryButton(
              label: 'Nộp lại hồ sơ',
              onPressed: () => context.pushReplacement('/kyc/upload'),
              icon: Icons.upload_rounded,
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Liên hệ hỗ trợ',
              onPressed: () {},
              icon: Icons.headset_mic_outlined,
            ),
          ],
        ),
    };
  }
}
