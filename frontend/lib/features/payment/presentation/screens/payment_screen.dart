import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:frontend/features/payment/presentation/screens/vnpay_webview_screen.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';

enum _PayMethod { vnpay, momo, zalopay, card }

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    this.successLocation,
    this.successExtra,
  });

  /// Đơn (PENDING_PAYMENT) cần thanh toán.
  final String bookingId;
  final double amount;

  /// Nơi điều hướng khi thanh toán thành công. Mặc định (null) → màn kết quả.
  /// Giá trị truyền vào opaque để màn thanh toán không phụ thuộc feature khác.
  final String? successLocation;
  final Object? successExtra;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PaymentCubit>(),
      child: _PaymentView(
        bookingId: bookingId,
        amount: amount,
        successLocation: successLocation,
        successExtra: successExtra,
      ),
    );
  }
}

class _PaymentView extends StatefulWidget {
  const _PaymentView({
    required this.bookingId,
    required this.amount,
    this.successLocation,
    this.successExtra,
  });

  final String bookingId;
  final double amount;
  final String? successLocation;
  final Object? successExtra;

  @override
  State<_PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<_PaymentView> {
  _PayMethod _selected = _PayMethod.vnpay;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) async {
        switch (state) {
          case PaymentSuccess():
            final next = widget.successLocation;
            if (next != null) {
              context.pushReplacement(next, extra: widget.successExtra);
            } else {
              context.pushReplacement(
                '/payment/result',
                extra: {'success': true, 'amount': widget.amount},
              );
            }
          case PaymentFailure():
            context.pushReplacement(
              '/payment/result',
              extra: {'success': false, 'amount': widget.amount},
            );
          case PaymentAwaitingGateway(:final paymentId, :final payUrl):
            // Mở cổng VNPay thật; chờ WebView bắt URL return.
            final params = await Navigator.of(context).push<Map<String, String>>(
              MaterialPageRoute(
                builder: (_) => VnpayWebViewScreen(payUrl: payUrl),
              ),
            );
            if (!context.mounted) return;
            final cubit = context.read<PaymentCubit>();
            if (params != null) {
              await cubit.confirmGateway(paymentId: paymentId, params: params);
            } else {
              cubit.cancelGateway();
            }
          case PaymentIdle():
          case PaymentProcessing():
            break;
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              const RvSliverAppBar(
                title: 'Thanh toán',
                subtitle: 'Chọn phương thức thanh toán',
                role: RvRole.renter,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _AmountCard(amount: widget.amount),
                      const SizedBox(height: 20),
                      _MethodSelector(
                        selected: _selected,
                        onChanged: (m) => setState(() => _selected = m),
                      ),
                      const SizedBox(height: 20),
                      _SecurityBadge(),
                      const SizedBox(height: 20),
                      BlocBuilder<PaymentCubit, PaymentState>(
                        builder: (context, state) {
                          final isProcessing = state is PaymentProcessing;
                          return PrimaryButton(
                            label: 'Thanh toán ${widget.amount.toInt()}K VNĐ',
                            onPressed: isProcessing
                                ? null
                                : () => context
                                      .read<PaymentCubit>()
                                      .pay(bookingId: widget.bookingId),
                            isLoading: isProcessing,
                            icon: Icons.lock_outline_rounded,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.amount});
  final double amount;

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
          const Text(
            'Số tiền thanh toán',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '${amount.toInt()}K VNĐ',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🔒  Thanh toán bảo mật SSL',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodSelector extends StatelessWidget {
  const _MethodSelector({
    required this.selected,
    required this.onChanged,
  });

  final _PayMethod selected;
  final ValueChanged<_PayMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    const methods = [
      (method: _PayMethod.vnpay, emoji: '🏦', name: 'VNPay', desc: 'Ví VNPay & ATM nội địa'),
      (method: _PayMethod.momo, emoji: '🟣', name: 'MoMo', desc: 'Ví điện tử MoMo'),
      (method: _PayMethod.zalopay, emoji: '🔵', name: 'ZaloPay', desc: 'Ví điện tử ZaloPay'),
      (method: _PayMethod.card, emoji: '💳', name: 'Thẻ quốc tế', desc: 'Visa / Mastercard'),
    ];

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
            'Phương thức thanh toán',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 14),
          ...methods.map((m) {
            final isSelected = selected == m.method;
            return GestureDetector(
              onTap: () => onChanged(m.method),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(13)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(m.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.darkText,
                            ),
                          ),
                          Text(
                            m.desc,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.mutedText),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 6 : 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified_user_outlined,
            size: 14, color: AppColors.mutedText),
        const SizedBox(width: 6),
        const Text(
          'Giao dịch được mã hóa 256-bit SSL',
          style: TextStyle(fontSize: 12, color: AppColors.mutedText),
        ),
      ],
    );
  }
}
