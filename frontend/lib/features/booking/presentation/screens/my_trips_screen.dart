import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/presentation/cubit/my_trips_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';

/// Danh sách chuyến (đơn đặt) của người thuê — tab "Chuyến" ở shell.
class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyTripsCubit>(
      create: (_) => sl<MyTripsCubit>()..load(),
      child: const _MyTripsView(),
    );
  }
}

class _MyTripsView extends StatelessWidget {
  const _MyTripsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: RefreshIndicator(
          onRefresh: () => context.read<MyTripsCubit>().load(),
          child: CustomScrollView(
            slivers: [
              RvSliverAppBar(
                title: l10n.tripsTitle,
                subtitle: l10n.tripsSubtitle,
                role: RvRole.renter,
              ),
              BlocBuilder<MyTripsCubit, MyTripsState>(
                builder: (context, state) => switch (state) {
                  MyTripsLoading() => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  MyTripsError(:final message) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: _Message(text: message),
                  ),
                  MyTripsLoaded(:final bookings) when bookings.isEmpty =>
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _Message(text: l10n.tripsEmpty),
                    ),
                  MyTripsLoaded(:final bookings, :final cancellingId) =>
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList.separated(
                        itemCount: bookings.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _TripCard(
                          booking: bookings[i],
                          isCancelling: cancellingId == bookings[i].id,
                        ),
                      ),
                    ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: context.palette.secondaryText),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.booking, required this.isCancelling});

  final Booking booking;
  final bool isCancelling;

  static const _cancellable = {
    BookingStatus.pendingPayment,
    BookingStatus.confirmed,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canCancel = _cancellable.contains(booking.status);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.tripsOrderNumber(
                  booking.id.substring(0, booking.id.length.clamp(0, 8)),
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.palette.darkText,
                ),
              ),
              _StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 10),
          _InfoLine(
            icon: Icons.event_outlined,
            text:
                '${_fmtDate(booking.startTime)} → '
                '${_fmtDate(booking.endTime)}',
          ),
          const SizedBox(height: 6),
          _InfoLine(
            icon: Icons.payments_outlined,
            text: '${_fmtVnd(booking.totalPrice)} đ',
          ),
          if (canCancel) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isCancelling ? null : () => _confirmCancel(context),
                icon: isCancelling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.close_rounded, size: 18),
                label: Text(
                  isCancelling ? l10n.tripsCancelling : l10n.tripsCancel,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<MyTripsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.tripsCancelTitle),
        content: Text(l10n.tripsCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonNo),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.tripsCancel),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.cancel(booking.id);
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.palette.mutedText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: context.palette.secondaryText,
            ),
          ),
        ),
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
