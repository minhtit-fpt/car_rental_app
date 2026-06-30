import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/admin/domain/entities/admin_metrics.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_metrics_cubit.dart';

/// Khối số liệu nâng cao của dashboard (KPI + donut + bar + top xe + feed đơn).
/// Tự vẽ chart bằng [CustomPaint] — không thêm package.
class AdminMetricsSection extends StatelessWidget {
  const AdminMetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminMetricsCubit, AdminMetricsState>(
      builder: (context, state) {
        return switch (state) {
          AdminMetricsLoading() => const _MetricsPlaceholder(),
          AdminMetricsError(:final message) => _MetricsError(
            message: message,
            onRetry: () => context.read<AdminMetricsCubit>().load(),
          ),
          AdminMetricsLoaded(:final metrics) => _MetricsBody(metrics: metrics),
        };
      },
    );
  }
}

class _MetricsBody extends StatelessWidget {
  const _MetricsBody({required this.metrics});
  final AdminMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _KpiGrid(kpi: metrics.kpi),
        const SizedBox(height: 16),
        _DonutCard(
          title: 'Booking theo trạng thái',
          segments: [
            for (final b in metrics.bookingsByStatus)
              _Segment(
                label: _bookingStatusLabel(b.status),
                value: b.count.toDouble(),
                color: _bookingStatusColor(b.status),
              ),
          ],
          centerValue: _formatCount(metrics.kpi.totalBookings),
          centerLabel: 'đơn',
        ),
        const SizedBox(height: 16),
        _FleetBarCard(items: metrics.vehiclesByType),
        const SizedBox(height: 16),
        _DonutCard(
          title: 'Phương thức thanh toán',
          segments: [
            for (final p in metrics.paymentsByMethod)
              _Segment(
                label: p.method,
                value: p.total,
                color: _paymentColor(p.method),
              ),
          ],
          centerValue: _formatRevenue(
            metrics.paymentsByMethod.fold(0, (s, p) => s + p.total),
          ),
          centerLabel: 'VNĐ',
          valueFormatter: _formatRevenue,
        ),
        const SizedBox(height: 16),
        _TopVehiclesCard(items: metrics.topVehicles),
        const SizedBox(height: 16),
        _RecentBookingsCard(items: metrics.recentBookings),
      ],
    );
  }
}

// ── KPI grid ───────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.kpi});
  final AdminKpi kpi;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _KpiCard(
        value: _formatCount(kpi.totalBookings),
        label: 'Tổng đơn',
        icon: Icons.receipt_long_outlined,
        color: AppColors.adminBlue,
      ),
      _KpiCard(
        value: '${(kpi.completionRate * 100).toStringAsFixed(0)}%',
        label: 'Tỉ lệ hoàn tất',
        icon: Icons.check_circle_outline,
        color: AppColors.success,
      ),
      _KpiCard(
        value: '${(kpi.cancellationRate * 100).toStringAsFixed(0)}%',
        label: 'Tỉ lệ hủy',
        icon: Icons.cancel_outlined,
        color: AppColors.danger,
      ),
      _KpiCard(
        value: kpi.avgRating.toStringAsFixed(1),
        label: 'Điểm đánh giá TB',
        icon: Icons.star_outline_rounded,
        color: AppColors.warning,
      ),
      _KpiCard(
        value:
            '${_formatCount(kpi.availableVehicles)}/'
            '${_formatCount(kpi.totalVehicles)}',
        label: 'Xe sẵn sàng / tổng',
        icon: Icons.directions_car_outlined,
        color: AppColors.adminTeal,
      ),
      _KpiCard(
        value: _formatCount(kpi.electricVehicles),
        label: 'Xe điện (EV)',
        icon: Icons.electric_bolt_outlined,
        color: const Color(0xFF22C55E),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 18, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.adminMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Donut card (booking status, payment method) ──────────────────────────────

class _Segment {
  const _Segment({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;
}

class _DonutCard extends StatelessWidget {
  const _DonutCard({
    required this.title,
    required this.segments,
    required this.centerValue,
    required this.centerLabel,
    this.valueFormatter,
  });

  final String title;
  final List<_Segment> segments;
  final String centerValue;
  final String centerLabel;
  final String Function(double)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    final visible = segments.where((s) => s.value > 0).toList();
    final total = visible.fold<double>(0, (s, e) => s + e.value);

    return _Card(
      title: title,
      child: total == 0
          ? const _EmptyHint('Chưa có dữ liệu')
          : Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: _DonutPainter(visible, total),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            centerValue,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.adminText,
                            ),
                          ),
                          Text(
                            centerLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.adminMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final s in visible)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: _LegendRow(
                            color: s.color,
                            label: s.label,
                            value:
                                valueFormatter?.call(s.value) ??
                                _formatCount(s.value.toInt()),
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

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.adminMuted),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.adminText,
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.segments, this.total);
  final List<_Segment> segments;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 18.0;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (math.min(size.width, size.height) - stroke) / 2,
    );
    var start = -math.pi / 2;
    for (final s in segments) {
      final sweep = (s.value / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt
        ..color = s.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.segments != segments || old.total != total;
}

// ── Fleet bar card ───────────────────────────────────────────────────────────

class _FleetBarCard extends StatelessWidget {
  const _FleetBarCard({required this.items});
  final List<VehicleTypeMetric> items;

  @override
  Widget build(BuildContext context) {
    final maxCount = items.fold<int>(0, (m, e) => math.max(m, e.count));

    return _Card(
      title: 'Đội xe theo loại',
      child: items.isEmpty
          ? const _EmptyHint('Chưa có xe')
          : Column(
              children: [
                for (final v in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _FleetBarRow(item: v, maxCount: maxCount),
                  ),
              ],
            ),
    );
  }
}

class _FleetBarRow extends StatelessWidget {
  const _FleetBarRow({required this.item, required this.maxCount});
  final VehicleTypeMetric item;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final fraction = maxCount == 0 ? 0.0 : item.count / maxCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _vehicleTypeLabel(item.type),
              style: const TextStyle(fontSize: 13, color: AppColors.adminText),
            ),
            Text(
              '${item.count}  ·  ⚡${item.electric}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.adminMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: AppColors.adminBorder,
            valueColor: const AlwaysStoppedAnimation(AppColors.adminBlue),
          ),
        ),
      ],
    );
  }
}

// ── Top vehicles ─────────────────────────────────────────────────────────────

class _TopVehiclesCard extends StatelessWidget {
  const _TopVehiclesCard({required this.items});
  final List<TopVehicle> items;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Top xe theo doanh thu',
      child: items.isEmpty
          ? const _EmptyHint('Chưa có doanh thu')
          : Column(
              children: [
                for (final v in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            v.title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.adminText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${v.trips} chuyến',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.adminMuted,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatRevenue(v.revenue),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
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

// ── Recent bookings feed ─────────────────────────────────────────────────────

class _RecentBookingsCard extends StatelessWidget {
  const _RecentBookingsCard({required this.items});
  final List<RecentBooking> items;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Đơn mới nhất',
      child: items.isEmpty
          ? const _EmptyHint('Chưa có đơn')
          : Column(
              children: [
                for (final b in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _bookingStatusColor(b.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            b.vehicleTitle,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.adminText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatRevenue(b.totalPrice),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.adminText,
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

// ── Shared chrome ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.adminText,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.adminMuted, fontSize: 13),
      ),
    );
  }
}

class _MetricsPlaceholder extends StatelessWidget {
  const _MetricsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.adminBlue),
      ),
    );
  }
}

class _MetricsError extends StatelessWidget {
  const _MetricsError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Số liệu chi tiết',
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(color: AppColors.adminMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

// ── Formatting + label/color maps ────────────────────────────────────────────

String _formatCount(int value) => value.toString().replaceAllMapped(
  RegExp(r'(\d)(?=(\d{3})+$)'),
  (m) => '${m[1]},',
);

String _formatRevenue(double value) {
  if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
  if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(0)}M';
  if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(0)}K';
  return value.toStringAsFixed(0);
}

String _bookingStatusLabel(String status) => switch (status) {
  'PENDING_PAYMENT' => 'Chờ thanh toán',
  'CONFIRMED' => 'Đã xác nhận',
  'IN_PROGRESS' => 'Đang thuê',
  'COMPLETED' => 'Hoàn tất',
  'CANCELLED' => 'Đã hủy',
  _ => status,
};

Color _bookingStatusColor(String status) => switch (status) {
  'PENDING_PAYMENT' => AppColors.warning,
  'CONFIRMED' => AppColors.adminBlue,
  'IN_PROGRESS' => AppColors.adminTeal,
  'COMPLETED' => AppColors.success,
  'CANCELLED' => AppColors.danger,
  _ => AppColors.adminMuted,
};

Color _paymentColor(String method) => switch (method) {
  'VNPAY' => AppColors.adminBlue,
  'MOMO' => const Color(0xFFA855F7),
  'STRIPE' => const Color(0xFF6366F1),
  'CASH' => AppColors.success,
  _ => AppColors.adminMuted,
};

String _vehicleTypeLabel(String type) => switch (type) {
  'CAR' => 'Ô tô',
  'MOTORBIKE' => 'Xe máy',
  'BICYCLE' => 'Xe đạp',
  _ => type,
};
