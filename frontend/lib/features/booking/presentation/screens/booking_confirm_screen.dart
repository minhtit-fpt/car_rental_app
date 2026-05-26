import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/secondary_button.dart';

const _months = [
  'Th1', 'Th2', 'Th3', 'Th4', 'Th5', 'Th6',
  'Th7', 'Th8', 'Th9', 'Th10', 'Th11', 'Th12',
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
    return BlocListener<BookingCubit, BookingFormState>(
      listenWhen: (p, c) => c.submitted && !p.submitted,
      listener: (context, _) => context.pushReplacement(
        '/booking/contract',
        extra: {'vehicle': vehicle, 'cubit': context.read<BookingCubit>()},
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              const RvSliverAppBar(
                title: 'Xác nhận đặt xe',
                subtitle: 'Kiểm tra thông tin trước khi đặt',
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
                          _PaymentMethodCard(),
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
                              label: 'Xác nhận & Thanh toán',
                              onPressed: s.isSubmitting
                                  ? null
                                  : () => context
                                      .read<BookingCubit>()
                                      .confirmBooking(),
                              isLoading: s.isSubmitting,
                              icon: Icons.lock_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // T&C note
                          const Text(
                            'Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của RideVN.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedText,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SecondaryButton(
                            label: 'Quay lại',
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${vehicle.year} · ${vehicle.isElectric ? 'Điện' : vehicle.type}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
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
                    const Text(
                      '15/06 → 17/06',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
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
                      vehicle.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      ' · ${vehicle.ownerName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết chuyến đi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Nhận xe',
            value: state.startDate != null ? _fmtDate(state.startDate!) : '—',
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.event_rounded,
            label: 'Trả xe',
            value: state.endDate != null ? _fmtDate(state.endDate!) : '—',
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.schedule_rounded,
            label: 'Thời gian',
            value: '${state.totalDays} ngày',
          ),
          if (state.withDelivery) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.local_shipping_outlined,
              label: 'Giao xe tại',
              value: state.deliveryAddress.isNotEmpty
                  ? state.deliveryAddress
                  : 'Địa chỉ giao xe',
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
          style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // VISA card visual
          Container(
            width: 52,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1F71), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thẻ tín dụng',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
                Text(
                  '**** **** **** 4242',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.mutedText,
          ),
        ],
      ),
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
    final days = state.totalDays;
    final rentalTotal = vehicle.pricePerDay * days;
    final insurance = rentalTotal * 0.05;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryLine(
            label: 'Thuê xe (${vehicle.pricePerDay.toInt()}K × $days ngày)',
            value: '${rentalTotal.toInt()}K',
          ),
          if (state.withDelivery)
            const _SummaryLine(label: 'Giao xe', value: '50K'),
          _SummaryLine(label: 'Bảo hiểm (5%)', value: '${insurance.toInt()}K'),
          _SummaryLine(label: 'Phí dịch vụ (3%)', value: '${(rentalTotal * 0.03).toInt()}K'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.border, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
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
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.secondaryText)),
          Text('$value VNĐ',
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đặt cọc & Hủy chuyến',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Đặt cọc 30% khi xác nhận. Hoàn 100% nếu hủy trước 24h nhận xe.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
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
