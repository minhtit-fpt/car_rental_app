import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/admin/domain/entities/admin_booking_item.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_bookings_cubit.dart';
import 'package:frontend/features/admin/presentation/widgets/admin_booking_format.dart';

/// Danh sách đơn cho ADMIN: lọc theo trạng thái + mở chi tiết để can thiệp.
class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  // (giá trị filter, nhãn) — null = tất cả.
  static const _filters = <(String?, String)>[
    (null, 'Tất cả'),
    ('PENDING_PAYMENT', 'Chờ TT'),
    ('CONFIRMED', 'Đã xác nhận'),
    ('IN_PROGRESS', 'Đang thuê'),
    ('COMPLETED', 'Hoàn tất'),
    ('CANCELLED', 'Đã huỷ'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.adminBg,
        appBar: AppBar(
          backgroundColor: AppColors.adminSurface,
          foregroundColor: AppColors.adminText,
          elevation: 0,
          title: const Text(
            'Quản lý đơn',
            style: TextStyle(
              color: AppColors.adminText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<AdminBookingsCubit, AdminBookingsState>(
          builder: (context, state) {
            final active = switch (state) {
              AdminBookingsLoaded(:final status) => status,
              _ => null,
            };
            return Column(
              children: [
                _FilterBar(active: active),
                Expanded(child: _Body(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.active});

  final String? active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: AppColors.adminSurface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: BookingListScreen._filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (value, label) = BookingListScreen._filters[i];
          final selected = value == active;
          return GestureDetector(
            onTap: () =>
                context.read<AdminBookingsCubit>().filterByStatus(value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.adminBlue : AppColors.adminCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? AppColors.adminBlue : AppColors.adminBorder,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.adminMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final AdminBookingsState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AdminBookingsLoading() => const Center(
        child: CircularProgressIndicator(color: AppColors.adminBlue),
      ),
      AdminBookingsError(:final message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.adminMuted),
          ),
        ),
      ),
      AdminBookingsLoaded(:final items) when items.isEmpty => const Center(
        child: Text(
          'Không có đơn nào',
          style: TextStyle(color: AppColors.adminMuted),
        ),
      ),
      AdminBookingsLoaded(:final items) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _BookingRow(item: items[i]),
      ),
    };
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.item});

  final AdminBookingItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = bookingStatusColor(item.status);
    return GestureDetector(
      onTap: () async {
        await context.push('/admin/booking/${item.id}', extra: item);
        if (context.mounted) context.read<AdminBookingsCubit>().refresh();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.adminSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.adminBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.vehicleTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.adminText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                _Badge(label: bookingStatusLabel(item.status), color: statusColor),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  formatVnd(item.totalPrice),
                  style: const TextStyle(
                    color: AppColors.adminText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (item.paymentStatus != null)
                  _Badge(
                    label: paymentStatusLabel(item.paymentStatus!),
                    color: paymentStatusColor(item.paymentStatus!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
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
