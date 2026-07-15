import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/search/search_session.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/vehicle_display_l10n.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';

String _fmtDate(DateTime d) {
  const months = [
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
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

class BookingDatePickerScreen extends StatelessWidget {
  const BookingDatePickerScreen({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<BookingCubit>();
        // Prefill theo ngày đã chọn ở thanh tìm kiếm màn chính (nếu có).
        final search = sl<SearchSession>();
        if (search.hasDates) {
          cubit.setDates(search.startDate!, search.endDate!);
        }
        return cubit;
      },
      child: _BookingDatePickerView(vehicle: vehicle),
    );
  }
}

class _BookingDatePickerView extends StatelessWidget {
  const _BookingDatePickerView({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: CustomScrollView(
          slivers: [
            RvSliverAppBar(
              title: l10n.bookingPickDatesTitle,
              subtitle: l10n.bookingPickDatesSubtitle,
              role: RvRole.renter,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _VehicleSummaryCard(vehicle: vehicle),
                    const SizedBox(height: 20),
                    _DateRangePicker(vehicle: vehicle),
                    const SizedBox(height: 20),
                    _DeliveryToggle(),
                    const SizedBox(height: 20),
                    _PriceSummary(vehicle: vehicle),
                    const SizedBox(height: 20),
                    BlocBuilder<BookingCubit, BookingFormState>(
                      builder: (context, state) => PrimaryButton(
                        label: l10n.commonContinue,
                        onPressed: state.datesSelected
                            ? () => context.push(
                                '/booking/confirm',
                                extra: {
                                  'vehicle': vehicle,
                                  'cubit': context.read<BookingCubit>(),
                                },
                              )
                            : null,
                        icon: Icons.arrow_forward_rounded,
                      ),
                    ),
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

class _VehicleSummaryCard extends StatelessWidget {
  const _VehicleSummaryCard({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
              child: Text(vehicle.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.palette.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vehicle.typeSummaryL10n(l10n),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.palette.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${vehicle.pricePerDayK.toInt()}K',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                l10n.vehiclePerDay,
                style: TextStyle(
                  fontSize: 11,
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

class _DateRangePicker extends StatefulWidget {
  const _DateRangePicker({required this.vehicle});
  final Vehicle vehicle;

  @override
  State<_DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<_DateRangePicker> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    // Hiển thị ngày cubit đã được seed sẵn (từ thanh tìm kiếm màn chính).
    final state = context.read<BookingCubit>().state;
    _start = state.startDate;
    _end = state.endDate;
  }

  Future<void> _pickDates() async {
    final cubit = context.read<BookingCubit>();
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: (_start != null && _end != null)
          ? DateTimeRange(start: _start!, end: _end!)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: context.palette.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (range != null && mounted) {
      setState(() {
        _start = range.start;
        _end = range.end;
      });
      cubit.setDates(range.start, range.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            l10n.bookingRentalPeriod,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.palette.darkText,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateBox(
                  label: l10n.bookingPickupDateLabel,
                  date: _start,
                  icon: Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: context.palette.mutedText,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateBox(
                  label: l10n.bookingReturnDateLabel,
                  date: _end,
                  icon: Icons.event_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickDates,
              icon: const Icon(
                Icons.date_range_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              label: Text(
                _start == null ? l10n.homeSelectDate : l10n.bookingChangeDate,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_start != null && _end != null) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                l10n.bookingDays(
                  _end!.difference(_start!).inDays.clamp(1, 365),
                ),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({required this.label, required this.date, required this.icon});

  final String label;
  final DateTime? date;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: date != null
            ? AppColors.primary.withAlpha(13)
            : context.palette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: date != null
              ? AppColors.primary.withAlpha(80)
              : context.palette.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: context.palette.mutedText),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                icon,
                size: 13,
                color: date != null ? AppColors.primary : context.palette.mutedText,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  date != null ? _fmtDate(date!) : '—',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: date != null
                        ? context.palette.darkText
                        : context.palette.mutedText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<BookingCubit, BookingFormState>(
      builder: (context, state) {
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
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('📦', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.bookingDelivery,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.palette.darkText,
                          ),
                        ),
                        Text(
                          '+50K VNĐ',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.palette.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: state.withDelivery,
                    activeThumbColor: AppColors.teal,
                    activeTrackColor: AppColors.teal.withAlpha(80),
                    onChanged: (v) =>
                        context.read<BookingCubit>().toggleDelivery(value: v),
                  ),
                ],
              ),
              if (state.withDelivery) ...[
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) =>
                      context.read<BookingCubit>().setDeliveryAddress(v),
                  decoration: InputDecoration(
                    hintText: l10n.bookingDeliveryAddressHint,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: context.palette.mutedText,
                    ),
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: context.palette.mutedText,
                    ),
                    filled: true,
                    fillColor: context.palette.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.palette.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.palette.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: context.palette.darkText,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<BookingCubit, BookingFormState>(
      builder: (context, state) {
        if (!state.datesSelected) return const SizedBox.shrink();
        final days = state.totalDays;
        final rentalTotal = vehicle.pricePerDayK * days;
        final deliveryFee = state.withDelivery ? 50.0 : 0.0;
        final insurance = rentalTotal * 0.05;
        final total = rentalTotal + deliveryFee + insurance;

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
                l10n.bookingEstimatedCost,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.palette.darkText,
                ),
              ),
              const SizedBox(height: 12),
              _PriceLine(
                label: l10n.bookingRentalLine(
                  vehicle.pricePerDayK.toInt().toString(),
                  days,
                ),
                amount: rentalTotal,
              ),
              if (state.withDelivery)
                _PriceLine(label: l10n.bookingDeliveryFeeLabel, amount: 50),
              _PriceLine(label: l10n.bookingInsuranceLabel, amount: insurance),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: context.palette.border, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.bookingTotal,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.palette.darkText,
                    ),
                  ),
                  Text(
                    '${total.toInt()}K VNĐ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.label, required this.amount});
  final String label;
  final double amount;

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
            '${amount.toInt()}K VNĐ',
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
