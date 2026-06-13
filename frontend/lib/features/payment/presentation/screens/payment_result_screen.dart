import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/secondary_button.dart';

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
                  success ? 'Thanh toán thành công!' : 'Thanh toán thất bại',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: success
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  success
                      ? 'Chuyến đi của bạn đã được xác nhận.\nChúc bạn có chuyến đi vui vẻ!'
                      : 'Giao dịch không thành công.\nVui lòng thử lại hoặc chọn phương thức khác.',
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
                    label: 'Xem chuyến đi',
                    onPressed: () => context.go('/'),
                    icon: Icons.directions_car_rounded,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Về trang chủ',
                    onPressed: () => context.go('/'),
                    icon: Icons.home_outlined,
                  ),
                ] else ...[
                  PrimaryButton(
                    label: 'Thử lại',
                    onPressed: () => context.pop(),
                    icon: Icons.refresh_rounded,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Về trang chủ',
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
    final color =
        success ? AppColors.success : AppColors.danger;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          success ? '✅' : '❌',
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }
}

class _SuccessDetails extends StatelessWidget {
  const _SuccessDetails({required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) {
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
          _DetailRow(label: 'Số tiền', value: '${amount.toInt()}K VNĐ'),
          const SizedBox(height: 10),
          _DetailRow(label: 'Mã giao dịch', value: 'TXN${now.millisecondsSinceEpoch ~/ 1000}'),
          const SizedBox(height: 10),
          _DetailRow(label: 'Thời gian', value: '$timeStr · $dateStr'),
          const SizedBox(height: 10),
          _DetailRow(label: 'Trạng thái', value: '✅ Thành công'),
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
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.secondaryText)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText)),
      ],
    );
  }
}
