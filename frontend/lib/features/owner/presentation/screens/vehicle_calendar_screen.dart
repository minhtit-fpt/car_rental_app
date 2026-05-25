import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/status_chip.dart';

enum _DayStatus { available, booked, blocked, today }

class VehicleCalendarScreen extends StatefulWidget {
  const VehicleCalendarScreen({super.key});

  @override
  State<VehicleCalendarScreen> createState() => _VehicleCalendarScreenState();
}

class _VehicleCalendarScreenState extends State<VehicleCalendarScreen> {
  DateTime _focusedMonth = DateTime.now();

  // Mock: day 5-8 booked, day 15-16 blocked, rest available
  _DayStatus _statusFor(int day) {
    final today = DateTime.now();
    if (day == today.day &&
        _focusedMonth.month == today.month &&
        _focusedMonth.year == today.year) {
      return _DayStatus.today;
    }
    if (day >= 5 && day <= 8) { return _DayStatus.booked; }
    if (day == 15 || day == 16) { return _DayStatus.blocked; }
    return _DayStatus.available;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            const RvSliverAppBar(
              title: 'Lịch xe',
              subtitle: 'Quản lý lịch cho thuê',
              role: RvRole.owner,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _VehiclePicker(),
                    const SizedBox(height: 16),
                    _CalendarCard(
                      focusedMonth: _focusedMonth,
                      statusFor: _statusFor,
                      onMonthChanged: (d) =>
                          setState(() => _focusedMonth = d),
                    ),
                    const SizedBox(height: 16),
                    _LegendRow(),
                    const SizedBox(height: 20),
                    _UpcomingBookings(),
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

class _VehiclePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.cardImageGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🚗', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tesla Model 3',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  '2024 · Sedan · Điện',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          const Icon(Icons.expand_more_rounded,
              color: AppColors.mutedText),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedMonth,
    required this.statusFor,
    required this.onMonthChanged,
  });

  final DateTime focusedMonth;
  final _DayStatus Function(int day) statusFor;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
        focusedMonth.year, focusedMonth.month);
    final firstWeekday =
        DateTime(focusedMonth.year, focusedMonth.month, 1).weekday % 7;

    const monthNames = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded,
                    color: AppColors.darkText),
                onPressed: () => onMonthChanged(
                  DateTime(focusedMonth.year, focusedMonth.month - 1),
                ),
              ),
              Text(
                '${monthNames[focusedMonth.month - 1]} ${focusedMonth.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.darkText),
                onPressed: () => onMonthChanged(
                  DateTime(focusedMonth.year, focusedMonth.month + 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday) return const SizedBox.shrink();
              final day = index - firstWeekday + 1;
              final status = statusFor(day);
              return _DayCell(day: day, status: status);
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
      _DayStatus.today => (
          AppColors.primary,
          Colors.white,
          AppColors.primary,
        ),
      _DayStatus.booked => (
          const Color(0xFF10B981).withAlpha(26),
          const Color(0xFF10B981),
          const Color(0xFF10B981).withAlpha(80),
        ),
      _DayStatus.blocked => (
          const Color(0xFFEF4444).withAlpha(26),
          const Color(0xFFEF4444),
          const Color(0xFFEF4444).withAlpha(80),
        ),
      _DayStatus.available => (
          AppColors.surface,
          AppColors.darkText,
          Colors.transparent,
        ),
    };

    return GestureDetector(
      onTap: () {},
      child: Container(
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
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StatusChip(label: 'Đã đặt', color: const Color(0xFF10B981)),
        const SizedBox(width: 8),
        StatusChip(label: 'Khoá', color: const Color(0xFFEF4444)),
        const SizedBox(width: 8),
        StatusChip(label: 'Hôm nay', color: AppColors.primary),
      ],
    );
  }
}

class _UpcomingBookings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            'Đặt xe sắp tới',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _BookingRow(
            renter: 'Thanh N.',
            dates: '05/06 – 08/06',
            status: 'Đã xác nhận',
            statusColor: const Color(0xFF10B981),
          ),
          const Divider(color: AppColors.border, height: 20),
          _BookingRow(
            renter: 'Hùng T.',
            dates: '12/06 – 14/06',
            status: 'Chờ xác nhận',
            statusColor: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({
    required this.renter,
    required this.dates,
    required this.status,
    required this.statusColor,
  });

  final String renter;
  final String dates;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
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
              Text(renter,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  )),
              Text(dates,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.mutedText)),
            ],
          ),
        ),
        StatusChip(label: status, color: statusColor),
      ],
    );
  }
}
