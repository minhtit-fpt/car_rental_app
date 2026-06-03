import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/vehicle/presentation/screens/admin_dashboard_screen.dart';
import 'package:frontend/features/vehicle/presentation/screens/car_list_screen.dart';
import 'package:frontend/features/vehicle/presentation/screens/home_screen.dart';
import 'package:frontend/features/vehicle/presentation/screens/owner_dashboard_screen.dart';
import 'package:frontend/features/vehicle/presentation/screens/renter_dashboard_screen.dart';

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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.inkLight)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Tìm xe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car_rounded),
            label: 'Xe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map_rounded),
            label: 'Bản đồ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Tôi',
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
  int _role = 0; // 0=Renter, 1=Owner, 2=Admin

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Tài khoản',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkText),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _RoleChip(
                  label: '👤 Người thuê',
                  isActive: _role == 0,
                  onTap: () => setState(() => _role = 0),
                ),
                const SizedBox(width: 8),
                _RoleChip(
                  label: '🚗 Chủ xe',
                  isActive: _role == 1,
                  onTap: () => setState(() => _role = 1),
                ),
                const SizedBox(width: 8),
                _RoleChip(
                  label: '🛡️ Admin',
                  isActive: _role == 2,
                  onTap: () => setState(() => _role = 2),
                ),
              ],
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _role,
        children: const [
          RenterDashboardScreen(),
          OwnerDashboardScreen(),
          AdminDashboardScreen(),
        ],
      ),
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
          color: isActive ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : AppColors.secondaryText,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
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
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
