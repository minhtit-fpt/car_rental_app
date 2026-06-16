import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/admin/domain/entities/admin_kyc_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_kyc_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_users_cubit.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';

// ─────────────────────────────────────────────
// Mock Data
// ─────────────────────────────────────────────

enum _DisputePriority { high, medium, low }

class _Dispute {
  const _Dispute({
    required this.ref,
    required this.title,
    required this.timeAgo,
    required this.priority,
  });

  final String ref;
  final String title;
  final String timeAgo;
  final _DisputePriority priority;
}

const _kDisputes = [
  _Dispute(
    ref: 'BK lỗi #001',
    title: 'Trách nhiệm hư hỏng',
    timeAgo: '4 giờ trước',
    priority: _DisputePriority.high,
  ),
  _Dispute(
    ref: 'BK lỗi #002',
    title: 'Tính phí sai',
    timeAgo: '9 giờ trước',
    priority: _DisputePriority.medium,
  ),
  _Dispute(
    ref: 'BK lỗi #003',
    title: 'Trì hoãn bàn giao',
    timeAgo: '1 ngày trước',
    priority: _DisputePriority.low,
  ),
  _Dispute(
    ref: 'BK lỗi #004',
    title: 'Vấn đề bảo hiểm',
    timeAgo: '1 ngày trước',
    priority: _DisputePriority.medium,
  ),
  _Dispute(
    ref: 'BK lỗi #005',
    title: 'Hạn booking bất hợp',
    timeAgo: '2 ngày trước',
    priority: _DisputePriority.low,
  ),
];

// Revenue data: Th.11 → Th.4 (6 months)
const _kRevenueLabels = ['Th.11', 'Th.12', 'Th.1', 'Th.2', 'Th.3', 'Th.4'];
const _kRevenueValues = [320.0, 350.0, 290.0, 380.0, 440.0, 485.0];

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.adminBg,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            _AdminSliverAppBar(
              tabIndex: _tabIndex,
              onTabChanged: (i) => setState(() => _tabIndex = i),
            ),
          ],
          body: _AdminBody(
            tabIndex: _tabIndex,
            onTabChanged: (i) => setState(() => _tabIndex = i),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sliver App Bar
// ─────────────────────────────────────────────

class _AdminSliverAppBar extends StatelessWidget {
  const _AdminSliverAppBar({
    required this.tabIndex,
    required this.onTabChanged,
  });

  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 140,
      backgroundColor: AppColors.adminSurface,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: [
        IconButton(
          tooltip: 'Đăng xuất',
          icon: const Icon(Icons.logout_rounded, color: AppColors.adminText),
          onPressed: () => context.read<AuthCubit>().logout(),
        ),
      ],
      title: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'RideVN',
            style: TextStyle(
              color: AppColors.adminText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.danger.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'ADMIN',
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.adminBg, AppColors.adminSurface],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quản trị',
                    style: TextStyle(
                      color: AppColors.adminText,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '14/04/2026 · 09:30',
                    style: TextStyle(color: AppColors.adminMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: Container(
          color: AppColors.adminSurface,
          child: Row(
            children: [
              _AdminTab(
                label: 'Tổng quan',
                index: 0,
                current: tabIndex,
                onTap: onTabChanged,
              ),
              _AdminTab(
                label: 'KYC',
                index: 1,
                current: tabIndex,
                onTap: onTabChanged,
                badge: '23',
              ),
              _AdminTab(
                label: 'Người dùng',
                index: 2,
                current: tabIndex,
                onTap: onTabChanged,
              ),
              _AdminTab(
                label: 'Doanh thu',
                index: 3,
                current: tabIndex,
                onTap: onTabChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminTab extends StatelessWidget {
  const _AdminTab({
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
    this.badge,
  });

  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.adminBlue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive
                        ? AppColors.adminBlue
                        : AppColors.adminMuted,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────

class _AdminBody extends StatelessWidget {
  const _AdminBody({required this.tabIndex, required this.onTabChanged});

  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: switch (tabIndex) {
        1 => _KycTab(),
        2 => _UsersTab(),
        3 => _RevenueTab(),
        _ => _DashboardTab(onTabChanged: onTabChanged),
      },
    );
  }
}

// ─────────────────────────────────────────────
// Dashboard Tab
// ─────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.onTabChanged});

  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdminStatsGrid(),
        const SizedBox(height: 16),
        _KycQueueCard(onSeeAll: () => onTabChanged(1)),
        const SizedBox(height: 16),
        _DisputesCard(),
        const SizedBox(height: 16),
        _RecentUsersCard(onSeeAll: () => onTabChanged(2)),
        const SizedBox(height: 16),
        _RevenueChartCard(),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Admin Stats Grid
// ─────────────────────────────────────────────

class _AdminStatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminStatsState>(
      builder: (context, state) {
        if (state is AdminStatsError) {
          return _AdminStatsError(
            message: state.message,
            onRetry: () => context.read<AdminCubit>().loadStats(),
          );
        }
        final stats = state is AdminStatsLoaded ? state.stats : null;

        String count(int? v) => v == null ? '—' : _formatCount(v);
        String money(double? v) => v == null ? '—' : _formatRevenue(v);

        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _AdminStatCard(
              value: count(stats?.totalUsers),
              label: 'Tổng người dùng',
              icon: '👥',
              color: AppColors.adminBlue,
            ),
            _AdminStatCard(
              value: count(stats?.activeBookings),
              label: 'Booking đang hoạt động',
              icon: '📋',
              color: AppColors.adminTeal,
            ),
            _AdminStatCard(
              value: count(stats?.pendingKyc),
              label: 'KYC chờ duyệt',
              icon: '🔍',
              color: AppColors.warning,
            ),
            _AdminStatCard(
              value: money(stats?.monthlyRevenue),
              label: 'Doanh thu tháng (VNĐ)',
              icon: '💰',
              color: AppColors.success,
            ),
          ],
        );
      },
    );
  }
}

/// Định dạng số nguyên với dấu phân cách hàng nghìn (vd 2847 → "2,847").
String _formatCount(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
}

/// Doanh thu → dạng gọn theo triệu/tỷ VNĐ (vd 485000000 → "485M").
String _formatRevenue(double value) {
  if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
  if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(0)}M';
  if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(0)}K';
  return value.toStringAsFixed(0);
}

class _AdminStatsError extends StatelessWidget {
  const _AdminStatsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.adminMuted,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.adminMuted),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.adminMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// KYC Queue Card
// ─────────────────────────────────────────────

class _KycQueueCard extends StatelessWidget {
  const _KycQueueCard({required this.onSeeAll});

  final VoidCallback onSeeAll;

  static const int _previewLimit = 4;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminKycCubit, AdminKycState>(
      builder: (context, state) {
        final count = state is AdminKycLoaded ? state.items.length : null;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.adminCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.adminBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Hàng chờ KYC',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.adminText,
                          ),
                        ),
                        if (count != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withAlpha(51),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    TextButton(
                      onPressed: onSeeAll,
                      child: const Text(
                        'Xem tất cả →',
                        style: TextStyle(
                          color: AppColors.adminBlue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.adminBorder),
              switch (state) {
                AdminKycLoading() => const _AdminLoading(),
                AdminKycError(:final message) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: _AdminStatsError(
                    message: message,
                    onRetry: () => context.read<AdminKycCubit>().load(),
                  ),
                ),
                AdminKycLoaded(:final items) => _buildPreview(items),
              },
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreview(List<AdminKycItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Không có hồ sơ KYC chờ duyệt',
            style: TextStyle(color: AppColors.adminMuted, fontSize: 13),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final item in items.take(_previewLimit)) _KycListItem(item: item),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Disputes Card
// ─────────────────────────────────────────────

class _DisputesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tranh chấp đang xử lý',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.adminText,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.adminBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_kDisputes.length}',
                    style: const TextStyle(
                      color: AppColors.adminMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.adminBorder),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _kDisputes.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: AppColors.adminBorder),
            itemBuilder: (_, i) => _DisputeRow(dispute: _kDisputes[i]),
          ),
        ],
      ),
    );
  }
}

class _DisputeRow extends StatelessWidget {
  const _DisputeRow({required this.dispute});

  final _Dispute dispute;

  @override
  Widget build(BuildContext context) {
    final priorityInfo = _priorityInfo(dispute.priority);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: priorityInfo.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dispute.ref,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.adminText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${dispute.title} · ${dispute.timeAgo}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.adminMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: priorityInfo.color.withAlpha(38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              priorityInfo.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: priorityInfo.color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push('/admin/dispute/1'),
            child: const Text(
              'Tiếp nhận →',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.adminBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ({String label, Color color}) _priorityInfo(_DisputePriority priority) {
    return switch (priority) {
      _DisputePriority.high => (label: 'Cao', color: AppColors.danger),
      _DisputePriority.medium => (label: 'TB', color: AppColors.warning),
      _DisputePriority.low => (label: 'Thấp', color: AppColors.adminMuted),
    };
  }
}

// ─────────────────────────────────────────────
// Recent Users Card
// ─────────────────────────────────────────────

class _RecentUsersCard extends StatelessWidget {
  const _RecentUsersCard({required this.onSeeAll});

  final VoidCallback onSeeAll;

  static const int _previewLimit = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Người dùng mới nhất',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.adminText,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.adminBorder),
          BlocBuilder<AdminUsersCubit, AdminUsersState>(
            builder: (context, state) => switch (state) {
              AdminUsersLoading() => const _AdminLoading(),
              AdminUsersError(:final message) => Padding(
                padding: const EdgeInsets.all(16),
                child: _AdminStatsError(
                  message: message,
                  onRetry: () => context.read<AdminUsersCubit>().load(),
                ),
              ),
              AdminUsersLoaded(:final items) => _buildPreview(items),
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: TextButton(
                onPressed: onSeeAll,
                child: const Text(
                  'Xem tất cả người dùng →',
                  style: TextStyle(color: AppColors.adminBlue, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(List<AdminUserItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Chưa có người dùng',
            style: TextStyle(color: AppColors.adminMuted, fontSize: 13),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final user in items.take(_previewLimit)) _UserListItem(user: user),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Revenue Chart Card
// ─────────────────────────────────────────────

class _RevenueChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doanh thu 6 tháng gần nhất',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.adminText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Th.11 2025 - Th.4 2026 · Tổng: 2.265M VNĐ',
            style: TextStyle(fontSize: 11, color: AppColors.adminMuted),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 160, child: _RevenueBarChart()),
        ],
      ),
    );
  }
}

class _RevenueBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final maxValue = _kRevenueValues.reduce(math.max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(_kRevenueValues.length, (i) {
        final value = _kRevenueValues[i];
        final ratio = value / maxValue;
        final isHighest = value == maxValue;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${value.toInt()}M',
                  style: TextStyle(
                    fontSize: 9,
                    color: isHighest
                        ? AppColors.adminBlue
                        : AppColors.adminMuted,
                    fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: Duration(milliseconds: 400 + i * 60),
                  curve: Curves.easeOut,
                  height: 120 * ratio,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: isHighest
                          ? [
                              AppColors.adminBlue,
                              AppColors.adminBlue.withAlpha(178),
                            ]
                          : [
                              AppColors.adminTeal.withAlpha(77),
                              AppColors.adminTeal.withAlpha(46),
                            ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _kRevenueLabels[i],
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.adminMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// Phase 4 — Mock Data
// ─────────────────────────────────────────────

enum _UserFilter { all, renter, owner }

// ─────────────────────────────────────────────
// Helpers (data thật từ /api/admin/*)
// ─────────────────────────────────────────────

/// Hai ký tự viết tắt cho avatar — ưu tiên email, fallback số điện thoại.
String _initials(String? email, String phone) {
  final source = (email != null && email.isNotEmpty) ? email : phone;
  final cleaned = source.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  if (cleaned.isEmpty) return '?';
  return cleaned.substring(0, math.min(2, cleaned.length)).toUpperCase();
}

/// Khoảng thời gian tương đối tiếng Việt (vd "3 giờ trước").
String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays < 30) return '${diff.inDays} ngày trước';
  return '${(diff.inDays / 30).floor()} tháng trước';
}

class _AdminLoading extends StatelessWidget {
  const _AdminLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.adminBlue),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared Admin Tab Widgets
// ─────────────────────────────────────────────

class _SummaryItem {
  final String label;
  final String value;
  final Color color;
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _AdminSummaryRow extends StatelessWidget {
  const _AdminSummaryRow({required this.items});
  final List<_SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(items.length, (i) {
        final it = items[i];
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < items.length - 1 ? 8 : 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.adminCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.adminBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: it.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  it.value,
                  style: const TextStyle(
                    color: AppColors.adminText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  it.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.adminMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _AdminSearchBar extends StatelessWidget {
  const _AdminSearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.adminSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.adminText, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.adminMuted, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.adminMuted,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _AdminFilterChip extends StatelessWidget {
  const _AdminFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.adminBlue, AppColors.adminTeal],
                )
              : null,
          color: selected ? null : AppColors.adminSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.adminBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.adminText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// KYC Tab (full list)
// ─────────────────────────────────────────────

class _KycTab extends StatefulWidget {
  @override
  State<_KycTab> createState() => _KycTabState();
}

class _KycTabState extends State<_KycTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminKycCubit, AdminKycState>(
      builder: (context, state) {
        return switch (state) {
          AdminKycLoading() => const _AdminLoading(),
          AdminKycError(:final message) => _AdminStatsError(
            message: message,
            onRetry: () => context.read<AdminKycCubit>().load(),
          ),
          AdminKycLoaded(:final items) => _buildList(context, items),
        };
      },
    );
  }

  Widget _buildList(BuildContext context, List<AdminKycItem> items) {
    final q = _query.toLowerCase();
    final filtered = items
        .where(
          (k) =>
              k.phone.toLowerCase().contains(q) ||
              (k.email ?? '').toLowerCase().contains(q),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdminSummaryRow(
          items: [
            _SummaryItem(
              label: 'Chờ duyệt',
              value: '${items.length}',
              color: AppColors.warning,
            ),
            _SummaryItem(
              label: 'Hiển thị',
              value: '${filtered.length}',
              color: AppColors.adminTeal,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _AdminSearchBar(
          controller: _searchCtrl,
          hint: 'Tìm theo SĐT hoặc email...',
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.adminCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.adminBorder),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hàng đợi KYC (${filtered.length})',
                      style: const TextStyle(
                        color: AppColors.adminText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Cũ nhất trước',
                      style: TextStyle(
                        color: AppColors.adminMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.adminBorder, height: 1),
              ...filtered.map((k) => _KycListItem(item: k)),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Không có hồ sơ KYC chờ duyệt',
                    style: TextStyle(color: AppColors.adminMuted),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

Color _kycStatusColor(String status) => switch (status) {
  'PENDING' => AppColors.warning,
  'VERIFIED' => AppColors.success,
  'REJECTED' => AppColors.danger,
  _ => AppColors.adminMuted,
};

String _kycStatusLabel(String status) => switch (status) {
  'PENDING' => 'Chờ duyệt',
  'VERIFIED' => 'Đã duyệt',
  'REJECTED' => 'Từ chối',
  _ => 'Chưa nộp',
};

class _KycListItem extends StatelessWidget {
  const _KycListItem({required this.item});
  final AdminKycItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _kycStatusColor(item.status);
    final statusLabel = _kycStatusLabel(item.status);
    final title = item.email ?? item.phone;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.adminBorder, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.adminBlue, AppColors.adminTeal],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(item.email, item.phone),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.adminText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'CCCD + GPLX · ${_timeAgo(item.submittedAt)}',
                  style: const TextStyle(
                    color: AppColors.adminMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(38),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.adminMuted,
              size: 20,
            ),
            onPressed: () => context.push('/admin/kyc/${item.id}'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Users Tab
// ─────────────────────────────────────────────

class _UsersTab extends StatefulWidget {
  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  _UserFilter _filter = _UserFilter.all;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminUsersCubit, AdminUsersState>(
      builder: (context, state) {
        return switch (state) {
          AdminUsersLoading() => const _AdminLoading(),
          AdminUsersError(:final message) => _AdminStatsError(
            message: message,
            onRetry: () => context.read<AdminUsersCubit>().load(),
          ),
          AdminUsersLoaded(:final items) => _buildList(context, items),
        };
      },
    );
  }

  Widget _buildList(BuildContext context, List<AdminUserItem> items) {
    final q = _query.toLowerCase();
    final filtered = items.where((u) {
      final matchQuery =
          q.isEmpty ||
          u.phone.toLowerCase().contains(q) ||
          (u.email ?? '').toLowerCase().contains(q);
      final matchFilter = switch (_filter) {
        _UserFilter.all => true,
        _UserFilter.renter => u.hasRenter,
        _UserFilter.owner => u.hasOwner,
      };
      return matchQuery && matchFilter;
    }).toList();

    final renters = items.where((u) => u.hasRenter).length;
    final owners = items.where((u) => u.hasOwner).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdminSummaryRow(
          items: [
            _SummaryItem(
              label: 'Tổng',
              value: '${items.length}',
              color: AppColors.adminBlue,
            ),
            _SummaryItem(
              label: 'Người thuê',
              value: '$renters',
              color: AppColors.adminTeal,
            ),
            _SummaryItem(
              label: 'Chủ xe',
              value: '$owners',
              color: AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _AdminSearchBar(
          controller: _searchCtrl,
          hint: 'Tìm theo SĐT hoặc email...',
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _AdminFilterChip(
                label: 'Tất cả',
                selected: _filter == _UserFilter.all,
                onTap: () => setState(() => _filter = _UserFilter.all),
              ),
              const SizedBox(width: 8),
              _AdminFilterChip(
                label: 'Người thuê',
                selected: _filter == _UserFilter.renter,
                onTap: () => setState(() => _filter = _UserFilter.renter),
              ),
              const SizedBox(width: 8),
              _AdminFilterChip(
                label: 'Chủ xe',
                selected: _filter == _UserFilter.owner,
                onTap: () => setState(() => _filter = _UserFilter.owner),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.adminCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.adminBorder),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Người dùng (${filtered.length})',
                      style: const TextStyle(
                        color: AppColors.adminText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Mới nhất',
                      style: TextStyle(
                        color: AppColors.adminMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.adminBorder, height: 1),
              ...filtered.map((u) => _UserListItem(user: u)),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Không tìm thấy người dùng',
                    style: TextStyle(color: AppColors.adminMuted),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _UserListItem extends StatelessWidget {
  const _UserListItem({required this.user});
  final AdminUserItem user;

  @override
  Widget build(BuildContext context) {
    final bothRoles = user.hasOwner && user.hasRenter;
    final roleColor = bothRoles
        ? const Color(0xFFA855F7)
        : user.hasOwner
        ? AppColors.success
        : AppColors.adminTeal;
    final roleLabel = bothRoles
        ? 'Cả hai'
        : user.hasOwner
        ? 'Chủ xe'
        : 'Người thuê';
    final title = user.email ?? user.phone;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.adminBorder, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.adminBlue, AppColors.adminTeal],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(user.email, user.phone),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              if (user.isVerified)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.adminCard, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.adminText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 12,
                      color: AppColors.adminMuted,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '${user.phone} · ${_timeAgo(user.createdAt)}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.adminMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withAlpha(38),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              roleLabel,
              style: TextStyle(
                color: roleColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Revenue Tab
// ─────────────────────────────────────────────

class _RevenueTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_RevenueChartCard(), const SizedBox(height: 24)],
    );
  }
}
