import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:frontend/features/payment/presentation/screens/vnpay_webview_screen.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';

enum _PayMethod { vnpay, momo, zalopay, card }

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
            // Thanh toán xong → noti "Thanh toán thành công" vừa được tạo trên
            // backend; refresh để dấu đỏ + popup tới ngay, không đợi poll 30s.
            sl<NotificationCubit>().refresh();
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
            final params = await Navigator.of(context)
                .push<Map<String, String>>(
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
          backgroundColor: context.palette.background,
          body: CustomScrollView(
            slivers: [
              RvSliverAppBar(
                title: AppLocalizations.of(context).paymentTitle,
                subtitle: AppLocalizations.of(context).paymentSubtitle,
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
                            label: AppLocalizations.of(
                              context,
                            ).paymentPayAmount(_fmtVnd(widget.amount)),
                            onPressed: isProcessing
                                ? null
                                : () => context.read<PaymentCubit>().pay(
                                    bookingId: widget.bookingId,
                                  ),
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
          Text(
            AppLocalizations.of(context).paymentAmount,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '${_fmtVnd(amount)} VNĐ',
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
            child: Text(
              AppLocalizations.of(context).paymentSslBadge,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodSelector extends StatelessWidget {
  const _MethodSelector({required this.selected, required this.onChanged});

  final _PayMethod selected;
  final ValueChanged<_PayMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final methods = [
      (
        method: _PayMethod.vnpay,
        emoji: '🏦',
        name: 'VNPay',
        desc: l10n.paymentMethodVnpayDesc,
      ),
      (
        method: _PayMethod.momo,
        emoji: '🟣',
        name: 'MoMo',
        desc: l10n.paymentMethodMomoDesc,
      ),
      (
        method: _PayMethod.zalopay,
        emoji: '🔵',
        name: 'ZaloPay',
        desc: l10n.paymentMethodZalopayDesc,
      ),
      (
        method: _PayMethod.card,
        emoji: '💳',
        name: l10n.paymentMethodCard,
        desc: 'Visa / Mastercard',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paymentMethod,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.palette.darkText,
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
                      : context.palette.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : context.palette.border,
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
                                  : context.palette.darkText,
                            ),
                          ),
                          Text(
                            m.desc,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.palette.mutedText,
                            ),
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
                              : context.palette.border,
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
        Icon(
          Icons.verified_user_outlined,
          size: 14,
          color: context.palette.mutedText,
        ),
        const SizedBox(width: 6),
        Text(
          AppLocalizations.of(context).paymentSslEncryption,
          style: TextStyle(fontSize: 12, color: context.palette.mutedText),
        ),
      ],
    );
  }
}
