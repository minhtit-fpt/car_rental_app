import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/info_row.dart';

String _fmtVnd(int kAmount) {
  if (kAmount >= 1000) {
    final m = kAmount / 1000;
    if (m == m.truncateToDouble()) return '${m.truncate()}M VNĐ';
    return '${m.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '')}M VNĐ';
  }
  return '${kAmount}K VNĐ';
}

// ─────────────────────────────────────────────
// Mock Data
// ─────────────────────────────────────────────

enum _BookingStatus { active, completed, cancelled }

class _Booking {
  const _Booking({
    required this.carName,
    required this.carEmoji,
    required this.dateRange,
    required this.location,
    required this.bookingRef,
    required this.status,
    required this.price,
  });

  final String carName;
  final String carEmoji;
  final String dateRange;
  final String location;
  final String bookingRef;
  final _BookingStatus status;
  final int price;
}

const _kBookings = [
  _Booking(
    carName: 'BMW X5 xDrive',
    carEmoji: '🚙',
    dateRange: '05/04 → 08/04, 2026',
    location: 'HQ Guzm Office',
    bookingRef: 'BK-2024-002',
    status: _BookingStatus.active,
    price: 3750,
  ),
  _Booking(
    carName: 'Tesla Model 3',
    carEmoji: '🚗',
    dateRange: '15/03 → 18/03, 2026',
    location: 'Sân bay Nội Bài',
    bookingRef: 'BK-2024-001',
    status: _BookingStatus.completed,
    price: 2670,
  ),
  _Booking(
    carName: 'Toyota Camry',
    carEmoji: '🚗',
    dateRange: '10/02 → 12/02, 2026',
    location: 'Sân bay Tân Sơn Nhất',
    bookingRef: 'BK-2024-003',
    status: _BookingStatus.completed,
    price: 1100,
  ),
  _Booking(
    carName: 'Honda Civic RS',
    carEmoji: '🚗',
    dateRange: '22/01 → 24/01, 2026',
    location: 'Trung tâm Đà Nẵng',
    bookingRef: 'BK-2024-004',
    status: _BookingStatus.cancelled,
    price: 0,
  ),
];

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

class RenterDashboardScreen extends StatefulWidget {
  const RenterDashboardScreen({super.key});

  @override
  State<RenterDashboardScreen> createState() => _RenterDashboardScreenState();
}

class _RenterDashboardScreenState extends State<RenterDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() => _tabIndex = _tabController.index);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_Booking> get _filteredBookings {
    switch (_tabIndex) {
      case 1:
        return _kBookings
            .where((b) => b.status != _BookingStatus.active)
            .toList();
      default:
        // Sắp tới: active bookings
        return _kBookings
            .where((b) => b.status == _BookingStatus.active)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            _RenterSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatsRow(),
                    const SizedBox(height: 16),
                    _ProfileCard(),
                    const SizedBox(height: 16),
                    _BookingsCard(
                      tabController: _tabController,
                      bookings: _filteredBookings,
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

// ─────────────────────────────────────────────
// Sliver App Bar
// ─────────────────────────────────────────────

class _RenterSliverAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 150,
      backgroundColor: AppColors.primary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: AppColors.logoGradient,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'RideVN',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.renterHeaderGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Chuyến đi của tôi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Quản lý tất cả chuyến thuê xe',
                    style: TextStyle(
                      color: Colors.white.withAlpha(191),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '1',
            unit: 'xe',
            label: 'Đang Thuê',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '1',
            unit: 'chuyến',
            label: 'Sắp Tới',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '12',
            unit: 'chuyến',
            label: 'Tổng Chuyến',
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '850',
            unit: 'pts',
            label: 'Điểm thưởng',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  final String value;
  final String unit;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.mutedText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Profile Card
// ─────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
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
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4DABFF), Color(0xFF007BFF)],
              ),
            ),
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tuan Nguyen',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Thành viên từ 2024',
            style: TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
          const SizedBox(height: 8),
          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                5,
                (_) => const Text(
                  '★',
                  style: TextStyle(color: AppColors.starYellow, fontSize: 16),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '4.9',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const InfoRow(icon: Icons.email_outlined, text: 'tuan@email.com'),
          const SizedBox(height: 6),
          const InfoRow(icon: Icons.phone_outlined, text: '+84 912 345 678'),
          const SizedBox(height: 6),
          const InfoRow(
            icon: Icons.location_on_outlined,
            text: 'Hà Nội, Việt Nam',
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.credit_card_outlined,
                size: 16,
                color: AppColors.mutedText,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✓ KYC Đã xác minh',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              onPressed: () => context.push('/profile/edit'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Chỉnh sửa hồ sơ',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Bookings Card
// ─────────────────────────────────────────────

class _BookingsCard extends StatelessWidget {
  const _BookingsCard({required this.tabController, required this.bookings});

  final TabController tabController;
  final List<_Booking> bookings;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Text(
                  'Xe Đang Thuê',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tab bar — Sắp tới / Đã đi (orange underline per design)
          TabBar(
            controller: tabController,
            isScrollable: false,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.secondaryText,
            indicatorColor: AppColors.accent,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Sắp tới'),
              Tab(text: 'Đã đi'),
            ],
          ),
          const Divider(height: 1, color: AppColors.border),
          // Booking list
          if (bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Text('🚗', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 8),
                    Text(
                      'Không có chuyến nào',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookings.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (_, i) => _BookingRow(booking: bookings[i]),
            ),
        ],
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.booking});

  final _Booking booking;

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(booking.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Car emoji
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                booking.carEmoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.carName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 3),
                // Trip code — monospace
                Text(
                  booking.bookingRef,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                // Date strip
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 10,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        booking.dateRange,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status + price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusInfo.bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusInfo.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusInfo.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (booking.price > 0)
                Text(
                  _fmtVnd(booking.price),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  ({String label, Color bgColor, Color textColor}) _statusInfo(
    _BookingStatus status,
  ) {
    return switch (status) {
      _BookingStatus.active => (
        label: 'Đang thuê',
        bgColor: AppColors.primary.withAlpha(26),
        textColor: AppColors.primary,
      ),
      _BookingStatus.completed => (
        label: 'Hoàn thành',
        bgColor: AppColors.successSoft,
        textColor: AppColors.success,
      ),
      _BookingStatus.cancelled => (
        label: 'Đã hủy',
        bgColor: AppColors.dangerSoft,
        textColor: AppColors.danger,
      ),
    };
  }
}
