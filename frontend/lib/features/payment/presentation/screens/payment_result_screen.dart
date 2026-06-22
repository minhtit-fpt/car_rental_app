import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/secondary_button.dart';

/// Định dạng VND đầy đủ với dấu phân cách nghìn (vd: 1536000 → "1.536.000").
/// `amount` là tổng tiền thật của đơn (VND đầy đủ), không phải đơn vị nghìn (K).
String _fmtVnd(num v) {
  final s = v.round().abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}$buf';
}

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({
    super.key,
    required this.success,
    required this.amount,
  });

  final bool success;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                _ResultIcon(success: success),
                const SizedBox(height: 24),
                Text(
                  success
                      ? l10n.paymentResultSuccessTitle
                      : l10n.paymentResultFailTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: success ? AppColors.success : AppColors.danger,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  success
                      ? l10n.paymentResultSuccessBody
                      : l10n.paymentResultFailBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                if (success) _SuccessDetails(amount: amount),
                const Spacer(),
                if (success) ...[
                  PrimaryButton(
                    label: l10n.paymentViewTrip,
                    onPressed: () => context.go('/'),
                    icon: Icons.directions_car_rounded,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: l10n.paymentBackHome,
                    onPressed: () => context.go('/'),
                    icon: Icons.home_outlined,
                  ),
                ] else ...[
                  PrimaryButton(
                    label: l10n.commonRetry,
                    onPressed: () => context.pop(),
                    icon: Icons.refresh_rounded,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: l10n.paymentBackHome,
                    onPressed: () => context.go('/'),
                    icon: Icons.home_outlined,
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultIcon extends StatelessWidget {
  const _ResultIcon({required this.success});
  final bool success;

  @override
  Widget build(BuildContext context) {
    final color = success ? AppColors.success : AppColors.danger;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(success ? '✅' : '❌', style: const TextStyle(fontSize: 48)),
      ),
    );
  }
}

class _SuccessDetails extends StatelessWidget {
  const _SuccessDetails({required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withAlpha(60)),
      ),
      child: Column(
        children: [
          _DetailRow(
            label: l10n.paymentAmountLabel,
            value: '${_fmtVnd(amount)} VNĐ',
          ),
          const SizedBox(height: 10),
          _DetailRow(
            label: l10n.paymentTxnId,
            value: 'TXN${now.millisecondsSinceEpoch ~/ 1000}',
          ),
          const SizedBox(height: 10),
          _DetailRow(label: l10n.paymentTime, value: '$timeStr · $dateStr'),
          const SizedBox(height: 10),
          _DetailRow(
            label: l10n.paymentStatusLabel,
            value: l10n.paymentStatusSuccess,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}
