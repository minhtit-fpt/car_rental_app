import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:frontend/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/vehicle_display_l10n.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/secondary_button.dart';

const _months = [
  'Th1',
  'Th2',
  'Th3',
  'Th4',
  'Th5',
  'Th6',
  'Th7',
  'Th8',
  'Th9',
  'Th10',
  'Th11',
  'Th12',
];

String _fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

class BookingConfirmScreen extends StatelessWidget {
  const BookingConfirmScreen({
    super.key,
    required this.vehicle,
    required this.cubit,
  });

  final Vehicle vehicle;
  final BookingCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: _BookingConfirmView(vehicle: vehicle),
    );
  }
}

class _BookingConfirmView extends StatelessWidget {
  const _BookingConfirmView({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<BookingCubit, BookingFormState>(
          listenWhen: (p, c) => c.submitted && !p.submitted,
          listener: (context, _) {
            // Đơn vừa được tạo trên backend → refresh để noti "Đặt xe thành
            // công" + dấu đỏ + popup tới ngay, không đợi poll 30s.
            sl<NotificationCubit>().refresh();
            context.pushReplacement(
              '/booking/contract',
              extra: {
                'vehicle': vehicle,
                'cubit': context.read<BookingCubit>(),
              },
            );
          },
        ),
        BlocListener<BookingCubit, BookingFormState>(
          listenWhen: (p, c) =>
              c.errorMessage != null && c.errorMessage != p.errorMessage,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? l10n.bookingFailed),
                  backgroundColor: AppColors.accent,
                ),
              );
          },
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: context.palette.background,
          body: CustomScrollView(
            slivers: [
              RvSliverAppBar(
                title: l10n.bookingConfirmTitle,
                subtitle: l10n.bookingConfirmSubtitle,
                role: RvRole.renter,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BlocBuilder<BookingCubit, BookingFormState>(
                    builder: (context, state) {
                      final days = state.totalDays;
                      final rentalTotal = vehicle.pricePerDay * days;
                      final deliveryFee = state.withDelivery ? 50.0 : 0.0;
                      final insurance = rentalTotal * 0.05;
                      final total = rentalTotal + deliveryFee + insurance;

                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          _VehicleCard(vehicle: vehicle),
                          const SizedBox(height: 16),
                          _TripDetailsCard(state: state),
                          const SizedBox(height: 16),
                          _TotalCard(
                            vehicle: vehicle,
                            state: state,
                            total: total,
                          ),
                          const SizedBox(height: 20),
                          _InfoBanner(),
                          const SizedBox(height: 20),
                          BlocBuilder<BookingCubit, BookingFormState>(
                            builder: (context, s) => PrimaryButton(
                              label: l10n.bookingConfirmAndPay,
                              onPressed: s.isSubmitting
                                  ? null
                                  : () => context
                                        .read<BookingCubit>()
                                        .confirmBooking(vehicleId: vehicle.id),
                              isLoading: s.isSubmitting,
                              icon: Icons.lock_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // T&C note
                          Text(
                            l10n.bookingTermsNote,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.palette.mutedText,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SecondaryButton(
                            label: l10n.commonBack,
                            onPressed: () => context.pop(),
                            icon: Icons.arrow_back_rounded,
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
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

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 72×72 thumbnail
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.cardImageGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(vehicle.emoji, style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.palette.darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  vehicle.typeSummaryL10n(l10n),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.palette.mutedText,
                  ),
                ),
                const SizedBox(height: 6),
                // Dates split
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '15/06 → 17/06',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.palette.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Text(
                      '★',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.starYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      vehicle.rating?.toStringAsFixed(1) ?? '—',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.palette.secondaryText,
                      ),
                    ),
                    Text(
                      ' · ${vehicle.ownerName ?? l10n.vehicleOwnerFallback}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.palette.mutedText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripDetailsCard extends StatelessWidget {
  const _TripDetailsCard({required this.state});
  final BookingFormState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: l10n.bookingPickup,
            value: state.startDate != null ? _fmtDate(state.startDate!) : '—',
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.event_rounded,
            label: l10n.bookingReturn,
            value: state.endDate != null ? _fmtDate(state.endDate!) : '—',
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.schedule_rounded,
            label: l10n.bookingDuration,
            value: l10n.bookingDays(state.totalDays),
          ),
          if (state.withDelivery) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.local_shipping_outlined,
              label: l10n.bookingDeliveryTo,
              value: state.deliveryAddress.isNotEmpty
                  ? state.deliveryAddress
                  : l10n.bookingDeliveryAddressFallback,
            ),
          ],
        ],
      ),
    );
  }
}

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

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.vehicle,
    required this.state,
    required this.total,
  });
  final Vehicle vehicle;
  final BookingFormState state;
  final double total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = state.totalDays;
    final rentalTotal = vehicle.pricePerDay * days;
    final insurance = rentalTotal * 0.05;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryLine(
            label: l10n.bookingRentalCarLine(
              vehicle.pricePerDay.toInt().toString(),
              days,
            ),
            value: '${rentalTotal.toInt()}K',
          ),
          if (state.withDelivery)
            _SummaryLine(label: l10n.bookingDeliveryShort, value: '50K'),
          _SummaryLine(
            label: l10n.bookingInsuranceLabel,
            value: '${insurance.toInt()}K',
          ),
          _SummaryLine(
            label: l10n.bookingServiceFee,
            value: '${(rentalTotal * 0.03).toInt()}K',
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: context.palette.border, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.bookingTotalPayment,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.palette.darkText,
                ),
              ),
              Text(
                '${total.toInt()}K VNĐ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: context.palette.secondaryText,
            ),
          ),
          Text(
            '$value VNĐ',
            style: TextStyle(
              fontSize: 13,
              color: context.palette.darkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bookingDepositTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.palette.darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.bookingDepositBody,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.palette.secondaryText,
                    height: 1.4,
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
