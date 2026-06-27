import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/owner/domain/entities/owner_booking.dart';
import 'package:frontend/features/owner/presentation/cubit/owner_bookings_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle_availability.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_availability_cubit.dart';
import 'package:frontend/features/vehicle/presentation/vehicle_display_l10n.dart';
import 'package:frontend/features/owner/presentation/cubit/my_vehicles_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/status_chip.dart';

enum _DayStatus { available, booked, pending, today }

class VehicleCalendarScreen extends StatelessWidget {
  const VehicleCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<MyVehiclesCubit>()..load()),
        BlocProvider(create: (_) => sl<OwnerBookingsCubit>()..load()),
        BlocProvider(create: (_) => sl<VehicleAvailabilityCubit>()),
      ],
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatefulWidget {
  const _CalendarView();

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  DateTime _focusedMonth = DateTime.now();
  String? _selectedVehicleId;

  void _selectVehicle(String id) {
    setState(() => _selectedVehicleId = id);
    context.read<VehicleAvailabilityCubit>().load(id);
  }

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
              title: l10n.ownerCalendarTitle,
              subtitle: l10n.ownerCalendarSubtitle,
              role: RvRole.owner,
            ),
            SliverToBoxAdapter(
              child: BlocConsumer<MyVehiclesCubit, MyVehiclesState>(
                listener: (context, state) {
                  if (state is MyVehiclesLoaded &&
                      state.vehicles.isNotEmpty &&
                      _selectedVehicleId == null) {
                    _selectVehicle(state.vehicles.first.id);
                  }
                },
                builder: (context, state) => switch (state) {
                  MyVehiclesLoading() => const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  MyVehiclesError(:final message) => _Centered(text: message),
                  MyVehiclesLoaded(:final vehicles) =>
                    vehicles.isEmpty
                        ? _Centered(text: l10n.ownerNoCars)
                        : _Body(
                            vehicles: vehicles,
                            selectedVehicleId: _selectedVehicleId,
                            focusedMonth: _focusedMonth,
                            onSelectVehicle: _selectVehicle,
                            onMonthChanged: (d) =>
                                setState(() => _focusedMonth = d),
                          ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.palette.mutedText),
      ),
    ),
  );
}

class _Body extends StatelessWidget {
  const _Body({
    required this.vehicles,
    required this.selectedVehicleId,
    required this.focusedMonth,
    required this.onSelectVehicle,
    required this.onMonthChanged,
  });

  final List<Vehicle> vehicles;
  final String? selectedVehicleId;
  final DateTime focusedMonth;
  final ValueChanged<String> onSelectVehicle;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final selected = vehicles.firstWhere(
      (v) => v.id == selectedVehicleId,
      orElse: () => vehicles.first,
    );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _SummaryHero(vehicleCount: vehicles.length),
          const SizedBox(height: 16),
          _VehiclePicker(
            vehicles: vehicles,
            selected: selected,
            onSelect: onSelectVehicle,
          ),
          const SizedBox(height: 16),
          BlocBuilder<VehicleAvailabilityCubit, VehicleAvailabilityState>(
            builder: (context, state) {
              final availability = state is VehicleAvailabilityLoaded
                  ? state.availability
                  : null;
              return _CalendarCard(
                focusedMonth: focusedMonth,
                availability: availability,
                loading: state is VehicleAvailabilityLoading,
                onMonthChanged: onMonthChanged,
              );
            },
          ),
          const SizedBox(height: 16),
          _LegendRow(),
          const SizedBox(height: 20),
          const _PendingRequests(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SummaryHero extends StatelessWidget {
  const _SummaryHero({required this.vehicleCount});
  final int vehicleCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<OwnerBookingsCubit, OwnerBookingsState>(
      builder: (context, state) {
        final pending = state is OwnerBookingsLoaded ? state.pending.length : 0;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.ownerHeaderGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.brandShadow,
          ),
          child: Row(
            children: [
              _HeroStat(label: l10n.ownerYourCars, value: '$vehicleCount'),
              Container(
                width: 1,
                height: 28,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _HeroStat(label: l10n.ownerPendingApproval, value: '$pending'),
            ],
          ),
        );
      },
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white60),
        ),
      ],
    );
  }
}

class _VehiclePicker extends StatelessWidget {
  const _VehiclePicker({
    required this.vehicles,
    required this.selected,
    required this.onSelect,
  });

  final List<Vehicle> vehicles;
  final Vehicle selected;
  final ValueChanged<String> onSelect;

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
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.cardImageGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(selected.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.palette.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  selected.typeLabelL10n(l10n),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.palette.mutedText,
                  ),
                ),
              ],
            ),
          ),
          if (vehicles.length > 1)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.expand_more_rounded,
                color: context.palette.mutedText,
              ),
              onSelected: onSelect,
              itemBuilder: (context) => vehicles
                  .map((v) => PopupMenuItem(value: v.id, child: Text(v.title)))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedMonth,
    required this.availability,
    required this.loading,
    required this.onMonthChanged,
  });

  final DateTime focusedMonth;
  final VehicleAvailability? availability;
  final bool loading;
  final ValueChanged<DateTime> onMonthChanged;

  _DayStatus _statusFor(int day) {
    final date = DateTime(focusedMonth.year, focusedMonth.month, day);
    final today = DateTime.now();
    final isToday =
        day == today.day &&
        focusedMonth.month == today.month &&
        focusedMonth.year == today.year;

    final interval = availability?.bookings
        .where((b) => b.coversDay(date))
        .toList();
    if (interval != null && interval.isNotEmpty) {
      final hasConfirmed = interval.any(
        (b) =>
            b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.inProgress,
      );
      if (hasConfirmed) return _DayStatus.booked;
      return _DayStatus.pending;
    }
    if (isToday) return _DayStatus.today;
    return _DayStatus.available;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      focusedMonth.year,
      focusedMonth.month,
    );
    final firstWeekday =
        DateTime(focusedMonth.year, focusedMonth.month, 1).weekday % 7;

    const monthNames = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: context.palette.darkText,
                ),
                onPressed: () => onMonthChanged(
                  DateTime(focusedMonth.year, focusedMonth.month - 1),
                ),
              ),
              Text(
                '${monthNames[focusedMonth.month - 1]} ${focusedMonth.year}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.palette.darkText,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: context.palette.darkText,
                ),
                onPressed: () => onMonthChanged(
                  DateTime(focusedMonth.year, focusedMonth.month + 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.palette.mutedText,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: firstWeekday + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstWeekday) return const SizedBox.shrink();
                final day = index - firstWeekday + 1;
                return _DayCell(day: day, status: _statusFor(day));
              },
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.status});
  final int day;
  final _DayStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, textColor, borderColor) = switch (status) {
      _DayStatus.today => (AppColors.accent, Colors.white, AppColors.accent),
      _DayStatus.booked => (AppColors.primary, Colors.white, AppColors.primary),
      _DayStatus.pending => (
        AppColors.warning.withAlpha(40),
        AppColors.warning,
        AppColors.warning.withAlpha(120),
      ),
      _DayStatus.available => (
        context.palette.surface,
        context.palette.darkText,
        Colors.transparent,
      ),
    };

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 13,
            fontWeight: status == _DayStatus.today
                ? FontWeight.bold
                : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StatusChip(
          label: l10n.bookingStatusConfirmed,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        StatusChip(label: l10n.ownerPendingApproval, color: AppColors.warning),
        const SizedBox(width: 8),
        StatusChip(label: l10n.ownerToday, color: AppColors.accent),
      ],
    );
  }
}

class _PendingRequests extends StatelessWidget {
  const _PendingRequests();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwnerBookingsCubit, OwnerBookingsState>(
      builder: (context, state) {
        if (state is OwnerBookingsLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is OwnerBookingsError) {
          return _Centered(text: state.message);
        }
        if (state is! OwnerBookingsLoaded) return const SizedBox.shrink();

        final pending = state.pending;
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
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).ownerNeedsResponse,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.palette.darkText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${pending.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (pending.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    AppLocalizations.of(context).ownerNoPendingRequests,
                    style: TextStyle(
                      color: context.palette.mutedText,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                ...pending.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PendingBookingCard(
                      booking: b,
                      busy: state.actingId == b.id,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PendingBookingCard extends StatelessWidget {
  const _PendingBookingCard({required this.booking, required this.busy});
  final OwnerBooking booking;
  final bool busy;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.palette.surfaceSunken,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.navySoft,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.renterDisplayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.palette.darkText,
                      ),
                    ),
                    Text(
                      '${booking.vehicleTitle} · ${_fmt(booking.startTime)}–${_fmt(booking.endTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.palette.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: l10n.ownerPendingApproval,
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy
                      ? null
                      : () => context.read<OwnerBookingsCubit>().reject(
                          booking.id,
                        ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.palette.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    foregroundColor: AppColors.danger,
                  ),
                  child: Text(
                    l10n.ownerReject,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: busy
                      ? null
                      : () => context.read<OwnerBookingsCubit>().approve(
                          booking.id,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    busy ? '...' : l10n.ownerApprove,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
