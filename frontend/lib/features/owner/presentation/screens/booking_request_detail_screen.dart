import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/owner/domain/entities/owner_booking.dart';
import 'package:frontend/features/owner/presentation/cubit/booking_action_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/secondary_button.dart';
import 'package:frontend/shared/widgets/status_chip.dart';

const double _kPlatformFeeRate = 0.10;

String _fmtVnd(num v) {
  final s = v.round().abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}$buf';
}

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class BookingRequestDetailScreen extends StatelessWidget {
  const BookingRequestDetailScreen({super.key, this.booking});

  /// Đơn cần xem xét — truyền qua `extra` của GoRouter từ màn danh sách.
  final OwnerBooking? booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final booking = this.booking;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: CustomScrollView(
          slivers: [
            RvSliverAppBar(
              title: l10n.ownerRequestDetailTitle,
              subtitle: l10n.ownerRequestDetailSubtitle,
              role: RvRole.owner,
            ),
            SliverToBoxAdapter(
              child: booking == null
                  ? const _MissingBooking()
                  : BlocProvider(
                      create: (_) => sl<BookingActionCubit>(),
                      child: _DetailBody(booking: booking),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingBooking extends StatelessWidget {
  const _MissingBooking();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Text(
          AppLocalizations.of(context).ownerNoRequestData,
          style: TextStyle(color: context.palette.mutedText),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.booking});
  final OwnerBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<BookingActionCubit, BookingActionState>(
      listener: (context, state) {
        if (state is BookingActionDone) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.status.name == 'confirmed'
                    ? l10n.ownerRequestApproved
                    : l10n.ownerRequestRejected,
              ),
            ),
          );
          context.pop(true);
        } else if (state is BookingActionError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final busy = state is BookingActionInProgress;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _RenterCard(booking: booking),
              const SizedBox(height: 16),
              _TripCard(booking: booking),
              const SizedBox(height: 16),
              _VehicleCard(booking: booking),
              const SizedBox(height: 16),
              _EarningsCard(total: booking.totalPrice),
              const SizedBox(height: 20),
              if (booking.isPending)
                _ActionButtons(
                  busy: busy,
                  onApprove: () =>
                      context.read<BookingActionCubit>().approve(booking.id),
                  onReject: () =>
                      context.read<BookingActionCubit>().reject(booking.id),
                )
              else
                _AlreadyHandled(status: booking.status),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
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
);

class _RenterCard extends StatelessWidget {
  const _RenterCard({required this.booking});
  final OwnerBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.renterDisplayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.palette.darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      booking.renterPhone,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.palette.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: context.palette.border, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              StatusChip(
                label: _statusLabel(booking, l10n),
                color: _statusColor(context, booking),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.ownerSentOn(_fmtDate(booking.createdAt)),
                style: TextStyle(
                  fontSize: 12,
                  color: context.palette.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.booking});
  final OwnerBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hours = booking.endTime.difference(booking.startTime).inHours;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bookingTripDetails,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.palette.darkText,
            ),
          ),
          const SizedBox(height: 14),
          _InfoLine(
            icon: Icons.calendar_today_rounded,
            label: l10n.bookingPickup,
            value: _fmtDate(booking.startTime),
          ),
          const SizedBox(height: 10),
          _InfoLine(
            icon: Icons.event_rounded,
            label: l10n.bookingReturn,
            value: _fmtDate(booking.endTime),
          ),
          const SizedBox(height: 10),
          _InfoLine(
            icon: Icons.schedule_rounded,
            label: l10n.bookingDuration,
            value: l10n.ownerHours(hours),
          ),
          const SizedBox(height: 10),
          _InfoLine(
            icon: Icons.local_shipping_outlined,
            label: l10n.bookingDeliveryShort,
            value: booking.deliveryRequested ? l10n.commonYes : l10n.commonNo,
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
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
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: context.palette.mutedText),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.palette.darkText,
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.booking});
  final OwnerBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final emoji = switch (booking.vehicleType) {
      'MOTORBIKE' => '🏍️',
      'BICYCLE' => '🚲',
      _ => '🚗',
    };
    final typeLabel = switch (booking.vehicleType) {
      'MOTORBIKE' => l10n.vehicleTypeMotorbike,
      'BICYCLE' => l10n.vehicleTypeBicycle,
      _ => l10n.vehicleTypeCar,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.cardImageGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.vehicleTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.palette.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.palette.mutedText,
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

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fee = total * _kPlatformFeeRate;
    final net = total - fee;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Column(
        children: [
          _EarnLine(label: l10n.ownerTotalRental, value: _fmtVnd(total)),
          const SizedBox(height: 8),
          _EarnLine(label: l10n.ownerPlatformFee, value: '-${_fmtVnd(fee)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.primary, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.ownerYouReceive,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.palette.darkText,
                ),
              ),
              Text(
                '${_fmtVnd(net)} VNĐ',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarnLine extends StatelessWidget {
  const _EarnLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: context.palette.secondaryText),
        ),
        Text(
          '$value VNĐ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.palette.darkText,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        PrimaryButton(
          label: busy ? l10n.ownerProcessing : l10n.ownerApproveRequest,
          onPressed: busy ? null : onApprove,
          icon: Icons.check_circle_outline_rounded,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: l10n.ownerReject,
          onPressed: busy ? null : onReject,
          icon: Icons.cancel_outlined,
        ),
      ],
    );
  }
}

class _AlreadyHandled extends StatelessWidget {
  const _AlreadyHandled({required this.status});
  final dynamic status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surfaceSunken,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.border),
      ),
      child: Text(
        AppLocalizations.of(context).ownerRequestHandled,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.palette.secondaryText),
      ),
    );
  }
}

String _statusLabel(OwnerBooking b, AppLocalizations l10n) =>
    switch (b.status.name) {
      'pendingPayment' => l10n.ownerStatusPendingConfirm,
      'confirmed' => l10n.ownerStatusConfirmed,
      'inProgress' => l10n.ownerStatusInProgress,
      'completed' => l10n.ownerStatusCompleted,
      'cancelled' => l10n.ownerStatusCancelled,
      _ => l10n.ownerStatusUnknown,
    };

Color _statusColor(BuildContext context, OwnerBooking b) =>
    switch (b.status.name) {
  'pendingPayment' => AppColors.warning,
  'confirmed' => AppColors.success,
  'inProgress' => AppColors.primary,
  'completed' => AppColors.teal,
  'cancelled' => AppColors.danger,
  _ => context.palette.mutedText,
};
