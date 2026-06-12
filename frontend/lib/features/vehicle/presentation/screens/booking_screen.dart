import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';
import 'package:frontend/features/booking/presentation/cubit/create_booking_cubit.dart';
import 'package:frontend/features/booking/presentation/cubit/create_booking_state.dart';
import 'package:frontend/features/payment/presentation/screens/payment_screen.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

String _formatPrice(double value) {
  final whole = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write('.');
    buffer.write(whole[i]);
  }
  return buffer.toString();
}

/// Màn đặt xe (MVP) — chọn thời gian + số giờ, gọi API tạo đơn.
/// Thanh toán sẽ nối ở Phase 4; đơn tạo ra ở trạng thái PENDING_PAYMENT.
class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateBookingCubit>(
      create: (_) => getIt<CreateBookingCubit>(),
      child: _BookingView(vehicle: vehicle),
    );
  }
}

class _BookingView extends StatefulWidget {
  const _BookingView({required this.vehicle});

  final Vehicle vehicle;

  @override
  State<_BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<_BookingView> {
  DateTime? _start;
  int _hours = 4;
  bool _delivery = false;

  double get _total => widget.vehicle.pricePerHour * _hours;

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _start ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start ?? now),
    );
    if (!mounted) return;
    setState(() {
      _start = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 8,
        time?.minute ?? 0,
      );
    });
  }

  void _confirm() {
    final start = _start;
    if (start == null) return;
    context.read<CreateBookingCubit>().submit(
          CreateBookingParams(
            vehicleId: widget.vehicle.id,
            startTime: start,
            endTime: start.add(Duration(hours: _hours)),
            deliveryRequested: _delivery,
          ),
        );
  }

  void _onStateChange(BuildContext context, CreateBookingState state) {
    if (state is CreateBookingSuccess) {
      // Đơn vừa tạo ở PENDING_PAYMENT → sang luôn màn thanh toán, thay thế màn
      // đặt xe để nút back không quay lại form.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<bool>(
          builder: (_) => PaymentScreen(
            bookingId: state.booking.id,
            amount: state.booking.totalPrice,
          ),
        ),
      );
    } else if (state is CreateBookingFailure) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final startLabel = _start == null
        ? 'Chọn thời gian nhận xe'
        : '${_start!.day}/${_start!.month}/${_start!.year} '
            '${_start!.hour.toString().padLeft(2, '0')}:'
            '${_start!.minute.toString().padLeft(2, '0')}';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: const Color(0xFF003380),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Đặt xe',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocListener<CreateBookingCubit, CreateBookingState>(
          listener: _onStateChange,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Card(
                child: Row(
                  children: [
                    Text(v.type.emoji, style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatPrice(v.pricePerHour)}đ/giờ',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thời gian nhận xe',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _pickStart,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              startLabel,
                              style: TextStyle(
                                fontSize: 14,
                                color: _start == null
                                    ? AppColors.mutedText
                                    : AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Số giờ thuê',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                        Row(
                          children: [
                            _StepButton(
                              icon: Icons.remove,
                              onTap: _hours > 1
                                  ? () => setState(() => _hours--)
                                  : null,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$_hours',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                            _StepButton(
                              icon: Icons.add,
                              onTap: _hours < 720
                                  ? () => setState(() => _hours++)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (v.deliveryAvailable) ...[
                const SizedBox(height: 16),
                _Card(
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Giao xe tận nơi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      Switch(
                        value: _delivery,
                        activeThumbColor: AppColors.primary,
                        onChanged: (v) => setState(() => _delivery = v),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng cộng',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      '${_formatPrice(_total)}đ',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<CreateBookingCubit, CreateBookingState>(
              builder: (context, state) {
                final submitting = state is CreateBookingSubmitting;
                final enabled = _start != null && !submitting;
                return FilledButton(
                  onPressed: enabled ? _confirm : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Xác nhận đặt xe',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ),
        ),
      ),
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
      child: child,
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary.withAlpha(26) : AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primary : AppColors.mutedText,
        ),
      ),
    );
  }
}
