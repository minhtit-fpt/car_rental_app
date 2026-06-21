import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/favorite/presentation/cubit/favorite_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/widgets/car_card.dart';

/// Màn "Xe đã lưu" — danh sách xe yêu thích của user. Dùng [FavoriteCubit]
/// singleton (cung cấp ở gốc app) để đồng bộ icon tim với card và màn chi tiết.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Tải lại để phản ánh thay đổi mới nhất từ server khi mở màn.
    context.read<FavoriteCubit>().load();
  }

  Future<void> _toggleFavorite(Vehicle v) async {
    final ok = await context.read<FavoriteCubit>().toggle(v);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không cập nhật được yêu thích, thử lại sau'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<FavoriteCubit, FavoriteState>(
          builder: (context, state) => CustomScrollView(
            slivers: [
              const _FavoritesSliverAppBar(),
              _buildBody(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FavoriteState state) {
    final vehicles = state.savedVehicles;

    // Lần tải đầu chưa có dữ liệu → spinner.
    if (state.status == FavoriteStatus.loading && vehicles.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.status == FavoriteStatus.error && vehicles.isEmpty) {
      return SliverFillRemaining(
        child: _ErrorState(
          message: state.errorMessage ?? 'Đã xảy ra lỗi',
          onRetry: () => context.read<FavoriteCubit>().load(),
        ),
      );
    }
    if (vehicles.isEmpty) {
      return const SliverFillRemaining(child: _EmptyState());
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      sliver: SliverList.separated(
        itemCount: vehicles.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final v = vehicles[index];
          return CarListTile(
            vehicle: v,
            isFavorite: state.isFavorite(v.id),
            onFavoriteToggle: () => _toggleFavorite(v),
            onTap: () => context.push('/vehicles/${v.id}', extra: v),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sliver App Bar — gradient renter
// ─────────────────────────────────────────────

class _FavoritesSliverAppBar extends StatelessWidget {
  const _FavoritesSliverAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(start: 56, bottom: 16),
        title: Text(
          'Xe đã lưu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        background: DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.renterHeaderGradient),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('🤍', style: TextStyle(fontSize: 56)),
            SizedBox(height: 16),
            Text(
              'Chưa có xe nào được lưu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Bấm vào biểu tượng trái tim trên xe để lưu lại xem sau',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Error state with retry
// ─────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

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
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              'Không tải được xe đã lưu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
