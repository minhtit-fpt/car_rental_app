import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/owner/domain/entities/owner_revenue.dart';
import 'package:frontend/features/owner/presentation/cubit/my_vehicles_cubit.dart';
import 'package:frontend/features/owner/presentation/cubit/owner_revenue_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/vehicle_display_l10n.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/info_row.dart';

String _fmtVnd(num v) {
  final s = v.round().abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '$buf';
}

/// Tìm thống kê của một xe theo id (null nếu chưa có trong báo cáo doanh thu).
OwnerVehicleStat? _statFor(List<OwnerVehicleStat> stats, String vehicleId) {
  for (final s in stats) {
    if (s.vehicleId == vehicleId) return s;
  }
  return null;
}

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<MyVehiclesCubit>()..load()),
        BlocProvider(create: (_) => sl<OwnerRevenueCubit>()..load()),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: RefreshIndicator(
          onRefresh: () async {
            final vehicles = context.read<MyVehiclesCubit>();
            final revenue = context.read<OwnerRevenueCubit>();
            await Future.wait([vehicles.load(), revenue.load()]);
          },
          child: CustomScrollView(
            slivers: [
              _OwnerSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _OwnerStatsRow(),
                      const SizedBox(height: 16),
                      _OwnerProfileCard(),
                      const SizedBox(height: 16),
                      _MyCarsCard(),
                      const SizedBox(height: 24),
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

class _OwnerSliverAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SliverAppBar(
      pinned: true,
      expandedHeight: 150,
      backgroundColor: AppColors.ownerHeaderGradient.colors.last,
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
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFCD34D).withAlpha(51),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFCD34D).withAlpha(102)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  l10n.roleOwner,
                  style: const TextStyle(
                    color: Color(0xFFFCD34D),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.forum_outlined, color: Colors.white),
          tooltip: l10n.ownerChatTooltip,
          onPressed: () => context.push('/conversations'),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.ownerHeaderGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    l10n.ownerDashboardTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.ownerDashboardSubtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(191),
                      fontSize: 12,
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

class _OwnerStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<OwnerRevenueCubit, OwnerRevenueState>(
            builder: (context, state) {
              final revenue = state is OwnerRevenueLoaded
                  ? _fmtVnd(state.revenue.monthRevenue)
                  : '—';
              return _OwnerStatCard(
                icon: '💰',
                value: revenue,
                unit: 'đ',
                label: l10n.ownerRevenueMonth,
                color: AppColors.warning,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: BlocBuilder<MyVehiclesCubit, MyVehiclesState>(
            builder: (context, state) {
              final count = state is MyVehiclesLoaded
                  ? '${state.vehicles.length}'
                  : '—';
              return _OwnerStatCard(
                icon: '🚗',
                value: count,
                unit: l10n.unitVehicles,
                label: l10n.ownerYourCars,
                color: AppColors.primary,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: BlocBuilder<OwnerRevenueCubit, OwnerRevenueState>(
            builder: (context, state) {
              final trips = state is OwnerRevenueLoaded
                  ? '${state.revenue.totalTrips}'
                  : '—';
              return _OwnerStatCard(
                icon: '📋',
                value: trips,
                unit: l10n.unitTrips,
                label: l10n.ownerTripsThisMonth,
                color: AppColors.success,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OwnerStatCard extends StatelessWidget {
  const _OwnerStatCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  final String icon;
  final String value;
  final String unit;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: context.palette.mutedText),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _OwnerProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = sl<AuthCubit>().state.user;
    final displayName = user?.email ?? user?.phone ?? l10n.roleOwner;
    final verified = user?.kycStatus.toUpperCase() == 'VERIFIED';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
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
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('👑', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.palette.darkText,
            ),
          ),
          const SizedBox(height: 16),
          if (user?.email != null)
            InfoRow(icon: Icons.email_outlined, text: user!.email!),
          if (user?.email != null) const SizedBox(height: 6),
          InfoRow(icon: Icons.phone_outlined, text: user?.phone ?? '—'),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 16,
                color: verified ? AppColors.success : context.palette.mutedText,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: verified
                      ? AppColors.successSoft
                      : context.palette.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  verified ? l10n.kycVerified : l10n.kycUnverifiedShort,
                  style: TextStyle(
                    fontSize: 11,
                    color: verified ? AppColors.success : context.palette.mutedText,
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
              child: Text(
                l10n.profileEdit,
                style: const TextStyle(
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

class _MyCarsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ownerMyCarsTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.palette.darkText,
                      ),
                    ),
                    Text(
                      l10n.ownerMyCarsSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.palette.mutedText,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/owner/vehicle/add'),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    l10n.ownerAddCar,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.palette.border),
          BlocBuilder<MyVehiclesCubit, MyVehiclesState>(
            builder: (context, state) => switch (state) {
              MyVehiclesLoading() => const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              ),
              MyVehiclesError(:final message) => Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
              MyVehiclesLoaded(:final vehicles) =>
                vehicles.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            l10n.ownerNoCars,
                            style: TextStyle(color: context.palette.mutedText),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vehicles.length,
                        separatorBuilder: (_, _) =>
                            Divider(height: 1, color: context.palette.border),
                        itemBuilder: (_, i) {
                          final v = vehicles[i];
                          return BlocBuilder<
                            OwnerRevenueCubit,
                            OwnerRevenueState
                          >(
                            builder: (context, rState) => _OwnedCarRow(
                              vehicle: v,
                              stat: rState is OwnerRevenueLoaded
                                  ? _statFor(rState.revenue.vehicles, v.id)
                                  : null,
                            ),
                          );
                        },
                      ),
            },
          ),
        ],
      ),
    );
  }
}

class _OwnedCarRow extends StatelessWidget {
  const _OwnedCarRow({required this.vehicle, this.stat});
  final Vehicle vehicle;
  final OwnerVehicleStat? stat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final available = vehicle.isAvailable;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.palette.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(vehicle.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.palette.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vehicle.typeLabelL10n(l10n),
                  style: TextStyle(
                    fontSize: 11,
                    color: context.palette.mutedText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.ownerPricePerDay(_fmtVnd(vehicle.pricePerDay)),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (stat != null) ...[
                  const SizedBox(height: 6),
                  _CarStatsLine(stat: stat!),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: available
                      ? AppColors.successSoft
                      : context.palette.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: available
                        ? AppColors.success.withAlpha(77)
                        : context.palette.border,
                  ),
                ),
                child: Text(
                  available ? l10n.ownerStatusReady : l10n.ownerStatusHidden,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: available ? AppColors.success : context.palette.mutedText,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionChip(
                    label: l10n.commonEdit,
                    color: context.palette.secondaryText,
                    onTap: () => _onEdit(context),
                  ),
                  const SizedBox(width: 6),
                  _ActionChip(
                    label: l10n.commonDelete,
                    color: AppColors.danger,
                    onTap: () => _confirmDelete(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onEdit(BuildContext context) async {
    final changed = await context.push<bool>(
      '/owner/vehicle/edit',
      extra: vehicle,
    );
    if (changed == true && context.mounted) {
      context.read<MyVehiclesCubit>().load();
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.ownerDeleteTitle),
        content: Text(l10n.ownerDeleteConfirm(vehicle.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<MyVehiclesCubit>().delete(vehicle.id);
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? l10n.ownerDeleteSuccess)),
    );
  }
}

/// Dòng số liệu theo xe: rating ⭐ · doanh thu · số chuyến.
class _CarStatsLine extends StatelessWidget {
  const _CarStatsLine({required this.stat});
  final OwnerVehicleStat stat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rating = stat.avgRating == null
        ? l10n.ownerCarNoRating
        : stat.avgRating!.toStringAsFixed(1);
    return Wrap(
      spacing: 10,
      runSpacing: 2,
      children: [
        _StatChip(icon: '⭐', text: rating),
        _StatChip(icon: '💰', text: '${_fmtVnd(stat.earnings)}đ'),
        _StatChip(icon: '🧾', text: '${stat.trips} ${l10n.unitTrips}'),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.text});
  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$icon $text',
      style: TextStyle(fontSize: 11, color: context.palette.mutedText),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: context.palette.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.palette.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
