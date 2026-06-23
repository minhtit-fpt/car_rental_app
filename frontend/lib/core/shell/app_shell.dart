import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/booking/presentation/screens/my_trips_screen.dart';
import 'package:frontend/features/vehicle/presentation/screens/car_list_screen.dart';
import 'package:frontend/features/vehicle/presentation/screens/home_screen.dart';
import 'package:frontend/features/vehicle/presentation/screens/owner_dashboard_screen.dart';
import 'package:frontend/features/vehicle/presentation/screens/renter_dashboard_screen.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onCarsTap: () => _navigateTo(1)),
          const CarListScreen(),
          const MyTripsScreen(),
          const _PlaceholderScreen(label: '🗺️', title: 'Map'),
          const _DashboardSelectorScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _navigateTo,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: context.palette.surface,
        border: Border(top: BorderSide(color: context.palette.inkLight)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_outlined),
            activeIcon: const Icon(Icons.search_rounded),
            label: l10n.navFindCar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.directions_car_outlined),
            activeIcon: const Icon(Icons.directions_car_rounded),
            label: l10n.navVehicles,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long_rounded),
            label: l10n.navTrips,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map_rounded),
            label: l10n.navMap,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            activeIcon: const Icon(Icons.person_rounded),
            label: l10n.navMe,
          ),
        ],
      ),
    );
  }
}

class _DashboardSelectorScreen extends StatefulWidget {
  const _DashboardSelectorScreen();

  @override
  State<_DashboardSelectorScreen> createState() =>
      _DashboardSelectorScreenState();
}

class _DashboardSelectorScreenState extends State<_DashboardSelectorScreen> {
  int _role = 0; // 0=Renter, 1=Owner (admin có khu vực riêng ở /admin)

  @override
  Widget build(BuildContext context) {
    // Chỉ tài khoản có vai OWNER mới thấy bộ chuyển Người thuê / Chủ xe.
    // Người thuê thuần tuý chỉ thấy dashboard Người thuê.
    final isOwner = context.watch<AuthCubit>().state.user?.isOwner ?? false;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        backgroundColor: context.palette.surface,
        title: Text(
          l10n.shellAccountTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.palette.darkText,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: Icon(
              Icons.settings_outlined,
              color: context.palette.darkText,
            ),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            tooltip: l10n.settingsLogout,
            icon: Icon(Icons.logout_rounded, color: context.palette.darkText),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
        bottom: isOwner
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: context.palette.surface,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      _RoleChip(
                        label: '👤 ${l10n.roleRenter}',
                        isActive: _role == 0,
                        onTap: () => setState(() => _role = 0),
                      ),
                      const SizedBox(width: 8),
                      _RoleChip(
                        label: '🚗 ${l10n.roleOwner}',
                        isActive: _role == 1,
                        onTap: () => setState(() => _role = 1),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: isOwner
          ? IndexedStack(
              index: _role,
              children: const [RenterDashboardScreen(), OwnerDashboardScreen()],
            )
          : const RenterDashboardScreen(),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : context.palette.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : context.palette.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : context.palette.secondaryText,
          ),
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label, required this.title});

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.palette.darkText,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '$title coming soon',
              style: TextStyle(
                fontSize: 16,
                color: context.palette.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
