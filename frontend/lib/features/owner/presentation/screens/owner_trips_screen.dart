import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/owner/domain/entities/owner_booking.dart';
import 'package:frontend/features/owner/presentation/cubit/owner_bookings_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/booking_status_badge.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';

/// Danh sách chuyến (đơn thuê) trên các xe của chủ xe — tab "Chuyến" ở
/// shell khi đang ở vai Chủ xe.
class OwnerTripsScreen extends StatelessWidget {
  const OwnerTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OwnerBookingsCubit>(
      create: (_) => sl<OwnerBookingsCubit>()..load(),
      child: const _OwnerTripsView(),
    );
  }
}

class _OwnerTripsView extends StatelessWidget {
  const _OwnerTripsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: RefreshIndicator(
          onRefresh: () => context.read<OwnerBookingsCubit>().load(),
          child: CustomScrollView(
            slivers: [
              RvSliverAppBar(
                title: l10n.ownerTripsTitle,
                subtitle: l10n.ownerTripsSubtitle,
                role: RvRole.owner,
              ),
              BlocBuilder<OwnerBookingsCubit, OwnerBookingsState>(
                builder: (context, state) => switch (state) {
                  OwnerBookingsLoading() => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  OwnerBookingsError(:final message) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: _Message(text: message),
                  ),
                  OwnerBookingsLoaded(:final bookings) when bookings.isEmpty =>
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _Message(text: l10n.ownerTripsEmpty),
                    ),
                  OwnerBookingsLoaded(:final bookings) => SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList.separated(
                      itemCount: bookings.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          _OwnerTripCard(booking: bookings[i]),
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

class _OwnerTripCard extends StatelessWidget {
  const _OwnerTripCard({required this.booking});
  final OwnerBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: () => context.push('/owner/booking-request', extra: booking),
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
                Expanded(
                  child: Text(
                    booking.vehicleTitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.palette.darkText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BookingStatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 10),
            _InfoLine(
              icon: Icons.person_outline_rounded,
              text: booking.renterDisplayName,
            ),
            const SizedBox(height: 6),
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
            if (booking.isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.ownerNeedsResponse,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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
