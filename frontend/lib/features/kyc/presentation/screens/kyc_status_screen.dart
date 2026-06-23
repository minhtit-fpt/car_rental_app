import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';
import 'package:frontend/features/kyc/presentation/cubit/kyc_status_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/secondary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';

enum KycStatus { unverified, pending, approved, rejected }

KycStatus _mapStatus(String s) => switch (s) {
  'VERIFIED' => KycStatus.approved,
  'REJECTED' => KycStatus.rejected,
  'PENDING' => KycStatus.pending,
  _ => KycStatus.unverified,
};

String _fmtDateTime(DateTime? d, String pendingLabel) {
  if (d == null) return pendingLabel;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
}

class KycStatusScreen extends StatelessWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            RvSliverAppBar(
              title: AppLocalizations.of(context).kycStatusTitle,
              subtitle: AppLocalizations.of(context).kycStatusSubtitle,
              role: RvRole.neutral,
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<KycStatusCubit, KycStatusState>(
                builder: (context, state) => switch (state) {
                  KycStatusLoading() => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  KycStatusFailure(:final message) => _ErrorBlock(
                    message: message,
                    onRetry: () => context.read<KycStatusCubit>().load(),
                  ),
                  KycStatusLoaded(:final info) => _Content(info: info),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.info});
  final KycStatusInfo info;

  @override
  Widget build(BuildContext context) {
    final status = _mapStatus(info.status);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _StatusCard(status: status),
          const SizedBox(height: 20),
          _TimelineCard(status: status, info: info),
          const SizedBox(height: 20),
          if (status == KycStatus.rejected &&
              (info.rejectReason?.isNotEmpty ?? false)) ...[
            _RejectionReasonCard(reason: info.rejectReason!),
            const SizedBox(height: 20),
          ],
          _ActionButtons(status: status),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Column(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).commonRetry),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});
  final KycStatus status;

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo(status, AppLocalizations.of(context));
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
            style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }

  ({String emoji, String title, String subtitle, Color color}) _statusInfo(
    KycStatus s,
    AppLocalizations l10n,
  ) {
    return switch (s) {
      KycStatus.unverified => (
        emoji: '📄',
        title: l10n.kycStatusUnverifiedTitle,
        subtitle: l10n.kycStatusUnverifiedSubtitle,
        color: AppColors.mutedText,
      ),
      KycStatus.pending => (
        emoji: '⏳',
        title: l10n.kycStatusPendingTitle,
        subtitle: l10n.kycStatusPendingSubtitle,
        color: AppColors.warning,
      ),
      KycStatus.approved => (
        emoji: '✅',
        title: l10n.kycStatusApprovedTitle,
        subtitle: l10n.kycStatusApprovedSubtitle,
        color: AppColors.success,
      ),
      KycStatus.rejected => (
        emoji: '❌',
        title: l10n.kycStatusRejectedTitle,
        subtitle: l10n.kycStatusRejectedSubtitle,
        color: AppColors.danger,
      ),
    };
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.status, required this.info});
  final KycStatus status;
  final KycStatusInfo info;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reviewed =
        status == KycStatus.approved || status == KycStatus.rejected;
    final steps = [
      _TimelineStep(
        label: l10n.kycStepSubmit,
        time: status == KycStatus.unverified
            ? l10n.kycNotSubmitted
            : _fmtDateTime(info.submittedAt, l10n.kycPending),
        isDone: status != KycStatus.unverified,
      ),
      _TimelineStep(
        label: l10n.kycStepReview,
        time: status == KycStatus.pending
            ? l10n.kycProcessing
            : reviewed
            ? _fmtDateTime(info.reviewedAt, l10n.kycPending)
            : l10n.kycPending,
        isDone: reviewed,
        isActive: status == KycStatus.pending,
      ),
      _TimelineStep(
        label: status == KycStatus.rejected
            ? l10n.kycStepRejected
            : l10n.kycStepComplete,
        time: reviewed
            ? _fmtDateTime(info.reviewedAt, l10n.kycPending)
            : l10n.kycPending,
        isDone: reviewed,
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
          Text(
            l10n.kycTimelineTitle,
            style: const TextStyle(
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
                color: step.isDone
                    ? AppColors.success.withAlpha(60)
                    : AppColors.border,
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
  const _RejectionReasonCard({required this.reason});
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withAlpha(13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.danger,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).kycRejectReason,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
            ),
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
    final l10n = AppLocalizations.of(context);
    return switch (status) {
      KycStatus.unverified => PrimaryButton(
        label: l10n.kycSubmitDocs,
        onPressed: () => context.push('/kyc/upload'),
        icon: Icons.upload_rounded,
      ),
      KycStatus.pending => SecondaryButton(
        label: l10n.paymentBackHome,
        onPressed: () => context.go('/'),
        icon: Icons.home_outlined,
      ),
      KycStatus.approved => PrimaryButton(
        label: l10n.kycFindCarNow,
        onPressed: () => context.go('/'),
        icon: Icons.directions_car_rounded,
      ),
      KycStatus.rejected => Column(
        children: [
          PrimaryButton(
            label: l10n.kycResubmit,
            onPressed: () => context.pushReplacement('/kyc/upload'),
            icon: Icons.upload_rounded,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: l10n.kycContactSupport,
            onPressed: () => context.push('/conversations'),
            icon: Icons.headset_mic_outlined,
          ),
        ],
      ),
    };
  }
}
