import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:frontend/features/payment/presentation/cubit/payment_state.dart';

String _formatPrice(double value) {
  final whole = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write('.');
    buffer.write(whole[i]);
  }
  return buffer.toString();
}

/// Màn thanh toán (Phase 4, VNPay mock-first). Tạo phiên rồi mô phỏng callback
/// cổng. Khi thành công, đơn chuyển sang CONFIRMED ở backend.
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  final String bookingId;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentCubit>(
      create: (_) => getIt<PaymentCubit>()..start(bookingId),
      child: _PaymentView(amount: amount),
    );
  }
}

class _PaymentView extends StatelessWidget {
  const _PaymentView({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: const Color(0xFF003380),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Thanh toán',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<PaymentCubit, PaymentFlowState>(
          builder: (context, state) {
            return switch (state) {
              PaymentCreating() =>
                const Center(child: CircularProgressIndicator()),
              PaymentReady(:final confirming) => _ReadyView(
                  amount: amount,
                  confirming: confirming,
                ),
              PaymentPaid() => const _PaidView(),
              PaymentFlowFailure(:final message, :final session) => _FailureView(
                  message: message,
                  canRetry: session != null,
                ),
            };
          },
        ),
      ),
    );
  }
}

class _ReadyView extends StatelessWidget {
  const _ReadyView({required this.amount, required this.confirming});

  final double amount;
  final bool confirming;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PaymentCubit>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VNPay (Sandbox)',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${_formatPrice(amount)}đ',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Số tiền cần thanh toán',
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 18, color: AppColors.mutedText),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Môi trường thử nghiệm — nhấn nút bên dưới để mô phỏng '
                  'kết quả thanh toán từ cổng.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: confirming ? null : () => cubit.confirm(success: true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: confirming
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
          label: Text(
            confirming ? 'Đang xử lý...' : 'Thanh toán ngay',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: confirming ? null : () => cubit.confirm(success: false),
          child: const Text(
            'Mô phỏng thanh toán thất bại',
            style: TextStyle(fontSize: 13, color: AppColors.mutedText),
          ),
        ),
      ],
    );
  }
}

class _PaidView extends StatelessWidget {
  const _PaidView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.teal.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Thanh toán thành công',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Đơn của bạn đã được xác nhận.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(220, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Xong',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message, required this.canRetry});

  final String message;
  final bool canRetry;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PaymentCubit>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: AppColors.orange),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            if (canRetry)
              FilledButton(
                onPressed: cubit.reset,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(220, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Thử lại',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            else
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(220, 50),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Quay lại'),
              ),
          ],
        ),
      ),
    );
  }
}
