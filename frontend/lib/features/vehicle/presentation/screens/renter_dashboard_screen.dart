import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/domain/entities/auth_user.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/presentation/cubit/my_trips_cubit.dart';
import 'package:frontend/features/loyalty/presentation/cubit/loyalty_cubit.dart';
import 'package:frontend/shared/widgets/info_row.dart';

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

/// Tab "Tôi" của người thuê: hồ sơ + chỉ số nhanh (điểm thưởng, số chuyến).
/// Danh sách chuyến đã chuyển hẳn sang tab "Chuyến" (MyTripsScreen).
class RenterDashboardScreen extends StatelessWidget {
  const RenterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MyTripsCubit>(create: (_) => sl<MyTripsCubit>()..load()),
        BlocProvider<LoyaltyCubit>(create: (_) => sl<LoyaltyCubit>()..load()),
      ],
      child: const _RenterDashboardView(),
    );
  }
}

class _RenterDashboardView extends StatelessWidget {
  const _RenterDashboardView();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              context.read<MyTripsCubit>().load(),
              context.read<LoyaltyCubit>().load(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              _RenterSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _StatsRow(),
                      SizedBox(height: 16),
                      _ProfileCard(),
                      SizedBox(height: 24),
                    ],
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
                    'Hồ sơ của tôi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tài khoản & điểm thưởng',
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
// Stats Row — đếm chuyến từ MyTripsCubit, điểm từ LoyaltyCubit
// ─────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyTripsCubit, MyTripsState>(
      builder: (context, tripsState) {
        final bookings = tripsState is MyTripsLoaded
            ? tripsState.bookings
            : const <Booking>[];
        final active = bookings
            .where((b) => b.status == BookingStatus.inProgress)
            .length;
        final upcoming = bookings
            .where((b) => b.status == BookingStatus.confirmed)
            .length;

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '$active',
                unit: 'xe',
                label: 'Đang Thuê',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: '$upcoming',
                unit: 'chuyến',
                label: 'Sắp Tới',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: '${bookings.length}',
                unit: 'chuyến',
                label: 'Tổng Chuyến',
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BlocBuilder<LoyaltyCubit, LoyaltyState>(
                builder: (context, loyaltyState) {
                  final points = loyaltyState is LoyaltyLoaded
                      ? loyaltyState.summary.totalPoints
                      : 0;
                  return _StatCard(
                    value: '$points',
                    unit: 'pts',
                    label: 'Điểm thưởng',
                    color: AppColors.success,
                  );
                },
              ),
            ),
          ],
        );
      },
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
// Profile Card — dữ liệu thật từ AuthCubit
// ─────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;

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
          Text(
            _displayName(user),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          _RoleBadges(user: user),
          const SizedBox(height: 16),
          if (user?.email != null) ...[
            InfoRow(icon: Icons.email_outlined, text: user!.email!),
            const SizedBox(height: 6),
          ],
          InfoRow(
            icon: Icons.phone_outlined,
            text: user?.phone ?? '—',
          ),
          const SizedBox(height: 6),
          _KycBadge(status: user?.kycStatus),
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

  /// Backend chưa có trường tên — ưu tiên email, fallback số điện thoại.
  String _displayName(AuthUser? user) {
    if (user == null) return 'Người dùng';
    final email = user.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return user.phone;
  }
}

class _RoleBadges extends StatelessWidget {
  const _RoleBadges({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      if (user?.isRenter ?? true) 'Người thuê',
      if (user?.isOwner ?? false) 'Chủ xe',
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      children: labels
          .map(
            (label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceSunken,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _KycBadge extends StatelessWidget {
  const _KycBadge({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final info = _kycInfo(status);

    return Row(
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
            color: info.bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            info.label,
            style: TextStyle(
              fontSize: 11,
              color: info.fg,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  ({String label, Color bg, Color fg}) _kycInfo(String? status) {
    switch (status?.toUpperCase()) {
      case 'VERIFIED':
        return (
          label: '✓ KYC Đã xác minh',
          bg: AppColors.successSoft,
          fg: AppColors.success,
        );
      case 'PENDING':
        return (
          label: '⏳ KYC Đang duyệt',
          bg: AppColors.warningSoft,
          fg: AppColors.warning,
        );
      case 'REJECTED':
        return (
          label: '✕ KYC Bị từ chối',
          bg: AppColors.dangerSoft,
          fg: AppColors.danger,
        );
      default:
        return (
          label: '! KYC Chưa xác minh',
          bg: AppColors.surfaceSunken,
          fg: AppColors.mutedText,
        );
    }
  }
}
