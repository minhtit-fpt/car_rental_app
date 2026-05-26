import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// Admin Design Tokens (dark theme)
// ─────────────────────────────────────────────

const _kAdminBg = Color(0xFF0A1628);
const _kAdminSurface = Color(0xFF142035);
const _kAdminCard = Color(0xFF1A2A40);
const _kAdminBorder = Color(0xFF253A54);
const _kAdminText = Color(0xFFE8F0FC);
const _kAdminMuted = Color(0xFF6B8AAD);
const _kAdminPrimary = Color(0xFF3B82F6);
const _kAdminTeal = Color(0xFF14B8A6);

// ─────────────────────────────────────────────
// Mock Data
// ─────────────────────────────────────────────

enum _KycType { cccd, cccdBike }

enum _KycStatus { pending, reviewing }

enum _DisputePriority { high, medium, low }

class _KycItem {
  const _KycItem({
    required this.name,
    required this.type,
    required this.timeAgo,
    required this.status,
    required this.emoji,
  });

  final String name;
  final _KycType type;
  final String timeAgo;
  final _KycStatus status;
  final String emoji;
}

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

class _RecentUser {
  const _RecentUser({
    required this.name,
    required this.location,
    required this.role,
    required this.emoji,
  });

  final String name;
  final String location;
  final String role;
  final String emoji;
}

const _kKycItems = [
  _KycItem(
    name: 'Nguyen Van An',
    type: _KycType.cccdBike,
    timeAgo: '2 giờ trước',
    status: _KycStatus.pending,
    emoji: '👨',
  ),
  _KycItem(
    name: 'Tran Thi Binh',
    type: _KycType.cccd,
    timeAgo: '4 giờ trước',
    status: _KycStatus.pending,
    emoji: '👩',
  ),
  _KycItem(
    name: 'Nguyen Minh Cuong',
    type: _KycType.cccdBike,
    timeAgo: '6 giờ trước',
    status: _KycStatus.reviewing,
    emoji: '👨',
  ),
  _KycItem(
    name: 'Pham Thu Dung',
    type: _KycType.cccd,
    timeAgo: '8 giờ trước',
    status: _KycStatus.pending,
    emoji: '👩',
  ),
  _KycItem(
    name: 'Hoang Manh Em',
    type: _KycType.cccdBike,
    timeAgo: '1 ngày trước',
    status: _KycStatus.pending,
    emoji: '👨',
  ),
];

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

const _kRecentUsers = [
  _RecentUser(
    name: 'Minh Hoang',
    location: 'Hà Nội',
    role: 'Renter',
    emoji: '👨',
  ),
  _RecentUser(
    name: 'Linh Phuong',
    location: 'Đà Nẵng',
    role: 'Owner',
    emoji: '👩',
  ),
  _RecentUser(
    name: 'Duc Anh',
    location: 'HCM',
    role: 'Renter',
    emoji: '👨',
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
        backgroundColor: _kAdminBg,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            _AdminSliverAppBar(
              tabIndex: _tabIndex,
              onTabChanged: (i) => setState(() => _tabIndex = i),
            ),
          ],
          body: _AdminBody(tabIndex: _tabIndex),
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
      backgroundColor: _kAdminSurface,
      systemOverlayStyle: SystemUiOverlayStyle.light,
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
              color: _kAdminText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'ADMIN',
              style: TextStyle(
                color: Color(0xFFEF4444),
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
              colors: [Color(0xFF0A1628), Color(0xFF142035)],
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
                      color: _kAdminText,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '14/04/2026 · 09:30',
                    style: TextStyle(
                      color: _kAdminMuted,
                      fontSize: 12,
                    ),
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
          color: _kAdminSurface,
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
                color: isActive ? _kAdminPrimary : Colors.transparent,
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
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? _kAdminPrimary : _kAdminMuted,
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
                      color: const Color(0xFFEF4444),
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
  const _AdminBody({required this.tabIndex});

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: switch (tabIndex) {
        1 => _KycTab(),
        2 => _UsersTab(),
        3 => _RevenueTab(),
        _ => _DashboardTab(),
      },
    );
  }
}

// ─────────────────────────────────────────────
// Dashboard Tab
// ─────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdminStatsGrid(),
        const SizedBox(height: 16),
        _KycQueueCard(),
        const SizedBox(height: 16),
        _DisputesCard(),
        const SizedBox(height: 16),
        _RecentUsersCard(),
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
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _AdminStatCard(
          value: '2,847',
          label: 'Tổng người dùng',
          icon: '👥',
          trend: '+12%',
          color: _kAdminPrimary,
        ),
        _AdminStatCard(
          value: '184',
          label: 'Booking đang hoạt động',
          icon: '📋',
          trend: '+8%',
          color: _kAdminTeal,
        ),
        _AdminStatCard(
          value: '23',
          label: 'KYC chờ duyệt',
          icon: '🔍',
          trend: '-2',
          color: Color(0xFFF59E0B),
        ),
        _AdminStatCard(
          value: '485M',
          label: 'Doanh thu tháng (VNĐ)',
          icon: '💰',
          trend: '+15%',
          color: Color(0xFF10B981),
        ),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.trend,
    required this.color,
  });

  final String value;
  final String label;
  final String icon;
  final String trend;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kAdminCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kAdminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(38),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
            style: const TextStyle(
              fontSize: 10,
              color: _kAdminMuted,
            ),
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

class _KycQueueCard extends StatefulWidget {
  @override
  State<_KycQueueCard> createState() => _KycQueueCardState();
}

class _KycQueueCardState extends State<_KycQueueCard> {
  final _approved = <int>{};
  final _rejected = <int>{};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kAdminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAdminBorder),
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
                        color: _kAdminText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withAlpha(51),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '23',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Xem tất cả →',
                    style: TextStyle(
                      color: _kAdminPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _kAdminBorder),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _kKycItems.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: _kAdminBorder),
            itemBuilder: (_, i) {
              final item = _kKycItems[i];
              final isApproved = _approved.contains(i);
              final isRejected = _rejected.contains(i);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _kAdminBorder,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kAdminText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _kAdminBorder,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.type == _KycType.cccdBike
                                      ? 'CCCD + BX'
                                      : 'CCCD',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: _kAdminMuted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.timeAgo,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: _kAdminMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status + actions
                    if (isApproved)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '✓ Đã duyệt',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (isRejected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '✗ Từ chối',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.status == _KycStatus.pending
                                  ? const Color(0xFFF59E0B).withAlpha(38)
                                  : _kAdminPrimary.withAlpha(38),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.status == _KycStatus.pending
                                  ? 'Chờ duyệt'
                                  : 'Đang xem xét',
                              style: TextStyle(
                                fontSize: 9,
                                color: item.status == _KycStatus.pending
                                    ? const Color(0xFFF59E0B)
                                    : _kAdminPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setState(() => _approved.add(i)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withAlpha(38),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Duyệt',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _rejected.add(i)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withAlpha(38),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Từ chối',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFEF4444),
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
            },
          ),
        ],
      ),
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
        color: _kAdminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAdminBorder),
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
                    color: _kAdminText,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _kAdminBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_kDisputes.length}',
                    style: const TextStyle(
                      color: _kAdminMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _kAdminBorder),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _kDisputes.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: _kAdminBorder),
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
                    color: _kAdminText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${dispute.title} · ${dispute.timeAgo}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kAdminMuted,
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
            onTap: () {},
            child: const Text(
              'Tiếp nhận →',
              style: TextStyle(
                fontSize: 11,
                color: _kAdminPrimary,
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
      _DisputePriority.high => (
          label: 'Cao',
          color: const Color(0xFFEF4444),
        ),
      _DisputePriority.medium => (
          label: 'TB',
          color: const Color(0xFFF59E0B),
        ),
      _DisputePriority.low => (
          label: 'Thấp',
          color: const Color(0xFF6B7280),
        ),
    };
  }
}

// ─────────────────────────────────────────────
// Recent Users Card
// ─────────────────────────────────────────────

class _RecentUsersCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kAdminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAdminBorder),
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
                color: _kAdminText,
              ),
            ),
          ),
          const Divider(height: 1, color: _kAdminBorder),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _kRecentUsers.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: _kAdminBorder),
            itemBuilder: (_, i) => _RecentUserRow(user: _kRecentUsers[i]),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Xem tất cả người dùng →',
                  style: TextStyle(color: _kAdminPrimary, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentUserRow extends StatelessWidget {
  const _RecentUserRow({required this.user});

  final _RecentUser user;

  @override
  Widget build(BuildContext context) {
    final isOwner = user.role == 'Owner';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kAdminBorder,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(user.emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kAdminText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.location,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kAdminMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isOwner
                  ? const Color(0xFFF59E0B).withAlpha(38)
                  : _kAdminPrimary.withAlpha(38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user.role,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isOwner ? const Color(0xFFF59E0B) : _kAdminPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Hoạt động',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
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
        color: _kAdminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAdminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doanh thu 6 tháng gần nhất',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _kAdminText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Th.11 2025 - Th.4 2026 · Tổng: 2.265M VNĐ',
            style: TextStyle(fontSize: 11, color: _kAdminMuted),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: _RevenueBarChart(),
          ),
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
                    color: isHighest ? _kAdminPrimary : _kAdminMuted,
                    fontWeight: isHighest
                        ? FontWeight.bold
                        : FontWeight.normal,
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
                              _kAdminPrimary,
                              _kAdminPrimary.withAlpha(178),
                            ]
                          : [
                              _kAdminTeal.withAlpha(77),
                              _kAdminTeal.withAlpha(46),
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
                    color: _kAdminMuted,
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

class _KycRequest {
  final String name;
  final String email;
  final String submittedAt;
  final String status;
  final String avatar;
  final String docType;
  const _KycRequest({
    required this.name,
    required this.email,
    required this.submittedAt,
    required this.status,
    required this.avatar,
    required this.docType,
  });
}

const _kKycMockData = <_KycRequest>[
  _KycRequest(name: 'Nguyễn Văn An', email: 'an.nv@gmail.com', submittedAt: '5 phút trước', status: 'pending', avatar: 'NA', docType: 'CCCD + GPLX'),
  _KycRequest(name: 'Trần Thị Bình', email: 'binh.tt@gmail.com', submittedAt: '12 phút trước', status: 'pending', avatar: 'TB', docType: 'CCCD + GPLX'),
  _KycRequest(name: 'Lê Hoàng Cường', email: 'cuong.lh@gmail.com', submittedAt: '1 giờ trước', status: 'reviewing', avatar: 'LC', docType: 'CCCD'),
  _KycRequest(name: 'Phạm Minh Đức', email: 'duc.pm@gmail.com', submittedAt: '2 giờ trước', status: 'pending', avatar: 'PD', docType: 'CCCD + GPLX'),
  _KycRequest(name: 'Hoàng Thị Em', email: 'em.ht@gmail.com', submittedAt: '3 giờ trước', status: 'reviewing', avatar: 'HE', docType: 'GPLX'),
  _KycRequest(name: 'Vũ Quang Huy', email: 'huy.vq@gmail.com', submittedAt: '5 giờ trước', status: 'pending', avatar: 'VH', docType: 'CCCD + GPLX'),
];

class _AdminUser {
  final String name;
  final String email;
  final String city;
  final String role;
  final String joinedAt;
  final String avatar;
  final bool verified;
  final int trips;
  const _AdminUser({
    required this.name,
    required this.email,
    required this.city,
    required this.role,
    required this.joinedAt,
    required this.avatar,
    required this.verified,
    required this.trips,
  });
}

const _kUsersMockData = <_AdminUser>[
  _AdminUser(name: 'Nguyễn Văn An', email: 'an.nv@gmail.com', city: 'Hà Nội', role: 'RENTER', joinedAt: '2 ngày trước', avatar: 'NA', verified: true, trips: 12),
  _AdminUser(name: 'Trần Thị Bình', email: 'binh.tt@gmail.com', city: 'TP.HCM', role: 'OWNER', joinedAt: '5 ngày trước', avatar: 'TB', verified: true, trips: 45),
  _AdminUser(name: 'Lê Hoàng Cường', email: 'cuong.lh@gmail.com', city: 'Đà Nẵng', role: 'BOTH', joinedAt: '1 tuần trước', avatar: 'LC', verified: true, trips: 28),
  _AdminUser(name: 'Phạm Minh Đức', email: 'duc.pm@gmail.com', city: 'Hà Nội', role: 'RENTER', joinedAt: '1 tuần trước', avatar: 'PD', verified: false, trips: 3),
  _AdminUser(name: 'Hoàng Thị Em', email: 'em.ht@gmail.com', city: 'Hải Phòng', role: 'OWNER', joinedAt: '2 tuần trước', avatar: 'HE', verified: true, trips: 67),
  _AdminUser(name: 'Vũ Quang Huy', email: 'huy.vq@gmail.com', city: 'TP.HCM', role: 'RENTER', joinedAt: '2 tuần trước', avatar: 'VH', verified: true, trips: 8),
  _AdminUser(name: 'Đỗ Thanh Lan', email: 'lan.dt@gmail.com', city: 'Cần Thơ', role: 'OWNER', joinedAt: '3 tuần trước', avatar: 'DL', verified: true, trips: 34),
  _AdminUser(name: 'Bùi Văn Minh', email: 'minh.bv@gmail.com', city: 'Nha Trang', role: 'RENTER', joinedAt: '1 tháng trước', avatar: 'BM', verified: true, trips: 15),
  _AdminUser(name: 'Ngô Thị Ngọc', email: 'ngoc.nt@gmail.com', city: 'Hà Nội', role: 'OWNER', joinedAt: '1 tháng trước', avatar: 'NN', verified: true, trips: 89),
  _AdminUser(name: 'Trịnh Quốc Phong', email: 'phong.tq@gmail.com', city: 'Đà Nẵng', role: 'BOTH', joinedAt: '2 tháng trước', avatar: 'TP', verified: true, trips: 52),
];

enum _UserFilter { all, renter, owner }

// ─────────────────────────────────────────────
// Shared Admin Tab Widgets
// ─────────────────────────────────────────────

class _SummaryItem {
  final String label;
  final String value;
  final Color color;
  const _SummaryItem({required this.label, required this.value, required this.color});
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
              color: _kAdminCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kAdminBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: it.color, shape: BoxShape.circle),
                ),
                const SizedBox(height: 8),
                Text(it.value,
                    style: const TextStyle(
                      color: _kAdminText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 2),
                Text(it.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _kAdminMuted, fontSize: 11)),
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
        color: _kAdminSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kAdminBorder),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: _kAdminText, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _kAdminMuted, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: _kAdminMuted, size: 20),
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
              ? const LinearGradient(colors: [_kAdminPrimary, _kAdminTeal])
              : null,
          color: selected ? null : _kAdminSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : _kAdminBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _kAdminText,
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
    final filtered = _kKycMockData.where((k) =>
        k.name.toLowerCase().contains(_query.toLowerCase()) ||
        k.email.toLowerCase().contains(_query.toLowerCase())).toList();

    final pending = _kKycMockData.where((k) => k.status == 'pending').length;
    final reviewing = _kKycMockData.where((k) => k.status == 'reviewing').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdminSummaryRow(items: [
          _SummaryItem(label: 'Chờ duyệt', value: '$pending', color: const Color(0xFFF59E0B)),
          _SummaryItem(label: 'Đang xem xét', value: '$reviewing', color: _kAdminTeal),
          _SummaryItem(label: 'Duyệt hôm nay', value: '142', color: const Color(0xFF10B981)),
        ]),
        const SizedBox(height: 16),
        _AdminSearchBar(
          controller: _searchCtrl,
          hint: 'Tìm theo tên hoặc email...',
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: _kAdminCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kAdminBorder),
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
                        color: _kAdminText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text('Mới nhất',
                        style: TextStyle(color: _kAdminMuted, fontSize: 12)),
                  ],
                ),
              ),
              const Divider(color: _kAdminBorder, height: 1),
              ...filtered.map((k) => _KycListItem(req: k)),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Không tìm thấy yêu cầu KYC',
                      style: TextStyle(color: _kAdminMuted)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _KycListItem extends StatelessWidget {
  const _KycListItem({required this.req});
  final _KycRequest req;

  @override
  Widget build(BuildContext context) {
    final statusColor = req.status == 'pending'
        ? const Color(0xFFF59E0B)
        : req.status == 'reviewing'
            ? _kAdminTeal
            : const Color(0xFF10B981);
    final statusLabel = req.status == 'pending'
        ? 'Chờ duyệt'
        : req.status == 'reviewing'
            ? 'Đang xem xét'
            : 'Đã duyệt';

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kAdminBorder, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kAdminPrimary, _kAdminTeal],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              req.avatar,
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
                Text(req.name,
                    style: const TextStyle(
                      color: _kAdminText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text(
                  '${req.docType} · ${req.submittedAt}',
                  style: const TextStyle(color: _kAdminMuted, fontSize: 12),
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
            icon: const Icon(Icons.chevron_right, color: _kAdminMuted, size: 20),
            onPressed: () {},
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
    final filtered = _kUsersMockData.where((u) {
      final matchQuery = _query.isEmpty ||
          u.name.toLowerCase().contains(_query.toLowerCase()) ||
          u.city.toLowerCase().contains(_query.toLowerCase());
      final matchFilter = _filter == _UserFilter.all ||
          (_filter == _UserFilter.renter &&
              (u.role == 'RENTER' || u.role == 'BOTH')) ||
          (_filter == _UserFilter.owner &&
              (u.role == 'OWNER' || u.role == 'BOTH'));
      return matchQuery && matchFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AdminSummaryRow(items: [
          _SummaryItem(label: 'Tổng người dùng', value: '2,847', color: _kAdminPrimary),
          _SummaryItem(label: 'Người thuê', value: '1,203', color: _kAdminTeal),
          _SummaryItem(label: 'Chủ xe', value: '1,644', color: Color(0xFF10B981)),
        ]),
        const SizedBox(height: 16),
        _AdminSearchBar(
          controller: _searchCtrl,
          hint: 'Tìm theo tên hoặc thành phố...',
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
            color: _kAdminCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kAdminBorder),
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
                        color: _kAdminText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text('Mới nhất',
                        style: TextStyle(color: _kAdminMuted, fontSize: 12)),
                  ],
                ),
              ),
              const Divider(color: _kAdminBorder, height: 1),
              ...filtered.map((u) => _UserListItem(user: u)),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Không tìm thấy người dùng',
                      style: TextStyle(color: _kAdminMuted)),
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
  final _AdminUser user;

  @override
  Widget build(BuildContext context) {
    final roleColor = user.role == 'OWNER'
        ? const Color(0xFF10B981)
        : user.role == 'BOTH'
            ? const Color(0xFFA855F7)
            : _kAdminTeal;
    final roleLabel = user.role == 'OWNER'
        ? 'Chủ xe'
        : user.role == 'BOTH'
            ? 'Cả hai'
            : 'Người thuê';

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kAdminBorder, width: 0.5)),
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
                    colors: [_kAdminPrimary, _kAdminTeal],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  user.avatar,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              if (user.verified)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: _kAdminCard, width: 2),
                    ),
                    child: const Icon(Icons.check, size: 8, color: Colors.white),
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
                  user.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _kAdminText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: _kAdminMuted),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '${user.city} · ${user.trips} chuyến · ${user.joinedAt}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _kAdminMuted, fontSize: 12),
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
      children: [
        _RevenueChartCard(),
        const SizedBox(height: 24),
      ],
    );
  }
}
