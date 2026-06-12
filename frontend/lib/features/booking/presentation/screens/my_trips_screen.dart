import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/presentation/cubit/my_trips_cubit.dart';
import 'package:frontend/features/booking/presentation/cubit/my_trips_state.dart';
import 'package:frontend/features/payment/presentation/screens/payment_screen.dart';

String _formatPrice(double value) {
  final whole = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write('.');
    buffer.write(whole[i]);
  }
  return buffer.toString();
}

String _formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  final d = '${local.day}/${local.month}/${local.year}';
  final t = '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
  return '$d $t';
}

Color _statusColor(BookingStatus status) => switch (status) {
      BookingStatus.pendingPayment => AppColors.orange,
      BookingStatus.confirmed => AppColors.primary,
      BookingStatus.inProgress => AppColors.teal,
      BookingStatus.completed => AppColors.mutedText,
      BookingStatus.cancelled => AppColors.mutedText,
    };

/// Danh sách đơn của tôi (Phase 3) — GET /api/bookings, huỷ đơn còn cho phép.
class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyTripsCubit>(
      create: (_) => getIt<MyTripsCubit>()..load(),
      child: const _MyTripsView(),
    );
  }
}

class _MyTripsView extends StatelessWidget {
  const _MyTripsView();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: const Color(0xFF003380),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Chuyến của tôi',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<MyTripsCubit, MyTripsState>(
          builder: (context, state) {
            return switch (state) {
              MyTripsLoading() =>
                const Center(child: CircularProgressIndicator()),
              MyTripsError(:final message) => _ErrorView(
                  message: message,
                  onRetry: () => context.read<MyTripsCubit>().load(),
                ),
              MyTripsLoaded(:final items, :final cancellingId) =>
                items.isEmpty
                    ? const _EmptyView()
                    : RefreshIndicator(
                        onRefresh: () => context.read<MyTripsCubit>().load(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) => _TripCard(
                            booking: items[i],
                            cancelling: cancellingId == items[i].id,
                          ),
                        ),
                      ),
            };
          },
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.booking, required this.cancelling});

  final Booking booking;
  final bool cancelling;

  Future<void> _confirmCancel(BuildContext context) async {
    final cubit = context.read<MyTripsCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Huỷ đơn?'),
        content: const Text('Bạn chắc chắn muốn huỷ đơn đặt xe này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Huỷ đơn'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final error = await cubit.cancel(booking.id);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _pay(BuildContext context) async {
    final cubit = context.read<MyTripsCubit>();
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PaymentScreen(
          bookingId: booking.id,
          amount: booking.totalPrice,
        ),
      ),
    );
    if (paid == true) await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '#${booking.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.play_circle_outline_rounded,
            label: 'Nhận xe',
            value: _formatDateTime(booking.startTime),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.stop_circle_outlined,
            label: 'Trả xe',
            value: _formatDateTime(booking.endTime),
          ),
          if (booking.deliveryRequested) ...[
            const SizedBox(height: 8),
            const _InfoRow(
              icon: Icons.local_shipping_outlined,
              label: 'Giao xe',
              value: 'Tận nơi',
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                '${_formatPrice(booking.totalPrice)}đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (booking.status == BookingStatus.pendingPayment) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: cancelling ? null : () => _pay(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.lock_rounded,
                    size: 18, color: Colors.white),
                label: const Text(
                  'Thanh toán',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          if (booking.status.isCancellable) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: cancelling ? null : () => _confirmCancel(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: cancelling
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.orange,
                        ),
                      )
                    : const Text(
                        'Huỷ đơn',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
        Icon(icon, size: 18, color: AppColors.mutedText),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.secondaryText,
          ),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧳', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Chưa có chuyến nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Đặt xe đầu tiên của bạn ngay thôi!',
            style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.orange),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
