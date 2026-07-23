import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/chat/presentation/cubit/start_conversation_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';

/// Chi tiết một đơn đặt — mở khi bấm vào card ở tab "Chuyến".
/// Đơn đã huỷ KHÔNG hiện nút kiểm tra xe (VLM) vì không có việc giao/trả.
class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showInspection = booking.status != BookingStatus.cancelled;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: CustomScrollView(
          slivers: [
            RvSliverAppBar(
              title: l10n.tripsDetailTitle,
              subtitle: l10n.tripsDetailSubtitle,
              role: RvRole.renter,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.tripsOrderNumber(booking.id),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: context.palette.darkText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _StatusBadge(status: booking.status),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            icon: Icons.event_outlined,
                            label: l10n.bookingRentalPeriod,
                            value:
                                '${_fmtDate(booking.startTime)} → '
                                '${_fmtDate(booking.endTime)}',
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.payments_outlined,
                            label: l10n.bookingTotal,
                            value: '${_fmtVnd(booking.totalPrice)} đ',
                          ),
                          if (booking.deliveryRequested) ...[
                            const SizedBox(height: 12),
                            _DetailRow(
                              icon: Icons.local_shipping_outlined,
                              label: l10n.bookingDelivery,
                              value: '✓',
                            ),
                          ],
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.schedule_outlined,
                            label: l10n.tripsBookedOn(
                              _fmtDate(booking.createdAt),
                            ),
                            value: '',
                          ),
                        ],
                      ),
                    ),
                    if (booking.status == BookingStatus.pendingPayment) ...[
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: l10n.tripsPay,
                        icon: Icons.payment_rounded,
                        onPressed: () {
                          // Chống double-tap: bỏ qua nếu đã rời màn này (đã push).
                          if (ModalRoute.of(context)?.isCurrent != true) return;
                          context.push(
                            '/payment',
                            extra: {
                              'bookingId': booking.id,
                              'amount': booking.totalPrice,
                              'successLocation': '/trips',
                            },
                          );
                        },
                      ),
                    ],
                    if (booking.status == BookingStatus.confirmed) ...[
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: l10n.trackingViewButton,
                        icon: Icons.navigation_rounded,
                        onPressed: () =>
                            context.push('/tracking/${booking.vehicleId}'),
                      ),
                    ],
                    if (showInspection) ...[
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: l10n.tripsInspectionCta,
                        icon: Icons.auto_awesome,
                        onPressed: () =>
                            context.push('/inspection/${booking.id}'),
                      ),
                    ],
                    if (booking.status != BookingStatus.cancelled) ...[
                      const SizedBox(height: 12),
                      _ChatWithOwnerButton(bookingId: booking.id),
                    ],
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

// ─────────────────────────────────────────────
// Nút "Nhắn tin với chủ xe" — tạo/lấy hội thoại theo booking rồi mở chat.
// ─────────────────────────────────────────────

class _ChatWithOwnerButton extends StatelessWidget {
  const _ChatWithOwnerButton({required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StartConversationCubit>(
      create: (_) => sl<StartConversationCubit>(),
      child: _ChatWithOwnerButtonView(bookingId: bookingId),
    );
  }
}

class _ChatWithOwnerButtonView extends StatelessWidget {
  const _ChatWithOwnerButtonView({required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<StartConversationCubit, StartConversationState>(
      listener: (context, state) {
        switch (state) {
          case StartConversationReady(:final conversationId, :final partnerName):
            context.push(
              '/chat/$conversationId',
              extra: partnerName ?? l10n.vehicleOwnerFallback,
            );
          case StartConversationError(:final message):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          case StartConversationIdle():
          case StartConversationInProgress():
        }
      },
      builder: (context, state) {
        final isLoading = state is StartConversationInProgress;
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () => context.read<StartConversationCubit>().open(
                    bookingId: bookingId,
                  ),
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: Text(l10n.chatWithOwner),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

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
      child: child,
    );
  }
}

/// Dòng: icon + nhãn (bên trái) và giá trị (bên phải). value rỗng = chỉ nhãn.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.palette.mutedText),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: context.palette.secondaryText,
            ),
          ),
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.palette.darkText,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      BookingStatus.pendingPayment => (
        l10n.bookingStatusPendingPayment,
        AppColors.accent,
      ),
      BookingStatus.awaitingOwner => (
        l10n.bookingStatusAwaitingOwner,
        AppColors.warning,
      ),
      BookingStatus.confirmed => (
        l10n.bookingStatusConfirmed,
        AppColors.primary,
      ),
      BookingStatus.inProgress => (
        l10n.bookingStatusInProgress,
        AppColors.teal,
      ),
      BookingStatus.completed => (
        l10n.bookingStatusCompleted,
        context.palette.mutedText,
      ),
      BookingStatus.cancelled => (
        l10n.bookingStatusCancelled,
        AppColors.danger,
      ),
      BookingStatus.unknown => ('—', context.palette.mutedText),
    };
    return Container(
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
    );
  }
}

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/${d.year}';

String _fmtVnd(double amount) {
  final s = amount.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}
