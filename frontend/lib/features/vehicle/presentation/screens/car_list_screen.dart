import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/favorite/presentation/cubit/favorite_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_cubit.dart';
import 'package:frontend/features/vehicle/presentation/widgets/car_card.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

enum _QuickFilter { all, saved, instant, auto, electric, five, seven }

String _filterLabel(_QuickFilter f, AppLocalizations l10n) => switch (f) {
  _QuickFilter.all => l10n.vehicleFilterAll,
  _QuickFilter.saved => l10n.vehicleFilterSaved,
  _QuickFilter.instant => l10n.vehicleFilterInstant,
  _QuickFilter.auto => l10n.vehicleFilterAuto,
  _QuickFilter.electric => l10n.vehicleFilterElectric,
  _QuickFilter.five => l10n.vehicleFilter5Seats,
  _QuickFilter.seven => l10n.vehicleFilter7Seats,
};

enum _SortOption { popular, priceLow, ratingHigh, nearest }

String _sortLabel(_SortOption o, AppLocalizations l10n) => switch (o) {
  _SortOption.popular => l10n.vehicleSortPopular,
  _SortOption.priceLow => l10n.vehicleSortPriceLow,
  _SortOption.ratingHigh => l10n.vehicleSortRatingHigh,
  _SortOption.nearest => l10n.vehicleSortNearest,
};

/// Giá trị bộ lọc nâng cao mà bottom sheet trả về khi người dùng bấm "Áp dụng".
typedef FilterResult = ({double maxPrice, double minRating});

/// Lọc danh sách xe theo chip nhanh "Xe điện" + bộ lọc nâng cao (giá/đánh giá).
///
/// Thuần hàm, không phụ thuộc widget → dễ kiểm thử đơn vị.
/// - [maxPrice]: ngưỡng giá/ngày tối đa (đơn vị K VNĐ, khớp [Vehicle.pricePerDay]);
///   `null` nghĩa là chưa áp dụng lọc giá.
/// - [minRating]: đánh giá tối thiểu; `null` nghĩa là chưa áp dụng. Xe chưa có
///   dữ liệu đánh giá (backend chưa trả) vẫn được giữ lại, không loại bỏ.
@visibleForTesting
List<Vehicle> applyVehicleFilters(
  List<Vehicle> vehicles, {
  bool electricOnly = false,
  double? maxPrice,
  double? minRating,
}) {
  return vehicles.where((v) {
    if (electricOnly && !v.isElectric) return false;
    if (maxPrice != null && v.pricePerDay > maxPrice) return false;
    if (minRating != null && v.hasRating && v.rating! < minRating) return false;
    return true;
  }).toList();
}

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  _QuickFilter _activeFilter = _QuickFilter.all;
  bool _showMap = false;
  _SortOption _sortBy = _SortOption.popular;

  /// Bộ lọc nâng cao từ bottom sheet — `null` khi người dùng chưa "Áp dụng".
  double? _maxPrice;
  double? _minRating;

  /// Lọc trên danh sách đã tải từ backend. Chỉ "Xe điện" có dữ liệu thật để
  /// lọc (isElectric); các chip còn lại chưa ánh xạ được sang trường backend
  /// nên tạm hiển thị tất cả. Giá/đánh giá đến từ bottom sheet (xem
  /// [applyVehicleFilters]).
  List<Vehicle> _applyFilter(List<Vehicle> all) {
    return applyVehicleFilters(
      all,
      electricOnly: _activeFilter == _QuickFilter.electric,
      maxPrice: _maxPrice,
      minRating: _minRating,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<VehicleListCubit, VehicleListState>(
        builder: (context, state) {
          final all = switch (state) {
            VehicleListLoaded(:final vehicles) => vehicles,
            _ => const <Vehicle>[],
          };
          // Theo dõi tập id đã lưu để icon tim cập nhật ngay khi đổi.
          final favorites = context.watch<FavoriteCubit>().state;
          // Bộ lọc "Đã lưu" lấy thẳng danh sách từ FavoriteCubit; các bộ lọc
          // khác lọc trên danh sách xe đã tải từ backend.
          final isSavedFilter = _activeFilter == _QuickFilter.saved;
          final vehicles = isSavedFilter
              ? favorites.savedVehicles
              : _applyFilter(all);
          return CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.darkText,
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        gradient: AppColors.logoGradient,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.vehicleFindCars,
                      style: const TextStyle(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: () => _showFilterSheet(context),
                  ),
                ],
              ),
              // Map strip + search overlay
              SliverToBoxAdapter(
                child: _MapStrip(
                  showMap: _showMap,
                  onToggleMap: () => setState(() => _showMap = !_showMap),
                  vehicles: vehicles,
                ),
              ),
              // Search bar (frosted overlay style)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _FrostedSearchCard(),
                ),
              ),
              // Filter chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                  child: _FilterChips(
                    active: _activeFilter,
                    onSelected: _onSelectFilter,
                  ),
                ),
              ),
              // Result count + sort
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isSavedFilter
                            ? l10n.vehicleCountSaved(vehicles.length)
                            : l10n.vehicleCountMatched(vehicles.length),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      _SortDropdown(
                        value: _sortBy,
                        onChanged: (v) =>
                            setState(() => _sortBy = v ?? _sortBy),
                      ),
                    ],
                  ),
                ),
              ),
              // Danh sách xe — "Đã lưu" theo FavoriteCubit, còn lại theo
              // VehicleListCubit.
              _buildResultsSliver(
                context,
                isSaved: isSavedFilter,
                vehicles: vehicles,
                listState: state,
                favorites: favorites,
              ),
            ],
          );
        },
      ),
    );
  }

  void _onSelectFilter(_QuickFilter f) {
    setState(() => _activeFilter = f);
    // Vào "Đã lưu" → làm mới danh sách yêu thích từ server.
    if (f == _QuickFilter.saved) {
      context.read<FavoriteCubit>().load();
    }
  }

  /// Sliver kết quả: nguồn dữ liệu + trạng thái tải/lỗi/rỗng tuỳ bộ lọc.
  Widget _buildResultsSliver(
    BuildContext context, {
    required bool isSaved,
    required List<Vehicle> vehicles,
    required VehicleListState listState,
    required FavoriteState favorites,
  }) {
    final isLoading = isSaved
        ? favorites.status == FavoriteStatus.loading && vehicles.isEmpty
        : listState is VehicleListLoading;
    if (isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final errorMessage = isSaved
        ? (favorites.status == FavoriteStatus.error && vehicles.isEmpty
              ? (favorites.errorMessage ??
                    AppLocalizations.of(context).commonError)
              : null)
        : (listState is VehicleListError ? listState.message : null);
    if (errorMessage != null) {
      return SliverFillRemaining(
        child: _ErrorState(
          message: errorMessage,
          onRetry: () {
            if (isSaved) {
              context.read<FavoriteCubit>().load();
            } else {
              context.read<VehicleListCubit>().load();
            }
          },
        ),
      );
    }

    if (vehicles.isEmpty) {
      return SliverFillRemaining(child: _EmptyState(saved: isSaved));
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
            isFavorite: favorites.isFavorite(v.id),
            onFavoriteToggle: () => _toggleFavorite(v),
            onTap: () => context.push('/vehicles/${v.id}', extra: v),
          );
        },
      ),
    );
  }

  /// Lưu/bỏ yêu thích; báo lỗi nếu cubit đã rollback do API thất bại.
  Future<void> _toggleFavorite(Vehicle v) async {
    final ok = await context.read<FavoriteCubit>().toggle(v);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).vehicleFavoriteError),
        ),
      );
    }
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterSheet(
        initialMaxPrice: _maxPrice ?? _kDefaultMaxPrice,
        initialMinRating: _minRating ?? _kDefaultMinRating,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _maxPrice = result.maxPrice;
      _minRating = result.minRating;
    });
  }
}

// ─────────────────────────────────────────────
// Map preview strip — 180px
// ─────────────────────────────────────────────

class _MapStrip extends StatelessWidget {
  const _MapStrip({
    required this.showMap,
    required this.onToggleMap,
    required this.vehicles,
  });

  final bool showMap;
  final VoidCallback onToggleMap;
  final List<Vehicle> vehicles;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: showMap ? 180 : 0,
      child: showMap
          ? Stack(
              children: [
                // Map background with grid
                Container(
                  color: const Color(0xFFE8EDF5),
                  child: CustomPaint(
                    painter: _MapRoadsPainter(),
                    child: const SizedBox.expand(),
                  ),
                ),
                // Price pills on map
                ..._buildPricePills(vehicles),
                // Toggle button
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _MapTogglePill(onTap: onToggleMap, showMap: showMap),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  List<Widget> _buildPricePills(List<Vehicle> vehicles) {
    // Mock positions for price pills on map
    const positions = [
      (left: 40.0, top: 30.0),
      (left: 140.0, top: 70.0),
      (left: 240.0, top: 40.0),
      (left: 80.0, top: 110.0),
    ];
    return List.generate(
      vehicles.length.clamp(0, positions.length),
      (i) => Positioned(
        left: positions[i].left,
        top: positions[i].top,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.brandShadow,
          ),
          child: Text(
            '${vehicles[i].pricePerDay.toInt()}K',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapRoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = const Color(0xFFD0D8E8)
      ..strokeWidth = 1;

    // Grid lines
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Roads
    canvas.drawLine(const Offset(0, 60), Offset(size.width, 60), roadPaint);
    canvas.drawLine(const Offset(0, 130), Offset(size.width, 130), roadPaint);
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(_MapRoadsPainter oldDelegate) => false;
}

class _MapTogglePill extends StatelessWidget {
  const _MapTogglePill({required this.onTap, required this.showMap});
  final VoidCallback onTap;
  final bool showMap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.brandShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              showMap ? Icons.list_rounded : Icons.map_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              showMap
                  ? AppLocalizations.of(context).vehicleListView
                  : AppLocalizations.of(context).vehicleMapView,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Frosted search card — location + dates
// ─────────────────────────────────────────────

class _FrostedSearchCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Location
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.vehicleLocationLabel,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          l10n.vehicleLocationPlaceholder,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.inkLight),
          // Dates
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 14, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.vehicleTimeLabel,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Text(
                          '15/06 → 17/06',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Filter chips — Vietnamese labels
// ─────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.active, required this.onSelected});

  final _QuickFilter active;
  final ValueChanged<_QuickFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _QuickFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _QuickFilter.values[i];
          final isActive = active == f;
          return GestureDetector(
            onTap: () => onSelected(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isActive ? AppColors.accent : AppColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _filterLabel(f, l10n),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.secondaryText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sort dropdown
// ─────────────────────────────────────────────

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});
  final _SortOption value;
  final ValueChanged<_SortOption?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonHideUnderline(
      child: DropdownButton<_SortOption>(
        value: value,
        onChanged: onChanged,
        isDense: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 16,
          color: AppColors.mutedText,
        ),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryText,
        ),
        items: [
          for (final option in _SortOption.values)
            DropdownMenuItem(
              value: option,
              child: Text(_sortLabel(option, l10n)),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.saved = false});

  /// True khi đang ở bộ lọc "Đã lưu" — đổi thông điệp cho phù hợp.
  final bool saved;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(saved ? '🤍' : '🚗', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              saved ? l10n.vehicleEmptySavedTitle : l10n.vehicleEmptyTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              saved
                  ? l10n.vehicleEmptySavedSubtitle
                  : l10n.vehicleEmptySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
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
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              l10n.vehicleListErrorTitle,
              style: const TextStyle(
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
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Filter bottom sheet
// ─────────────────────────────────────────────

// Ngưỡng mặc định + dải trượt cho bộ lọc nâng cao (giá theo K VNĐ).
const double _kDefaultMaxPrice = 1500;
const double _kMinPrice = 300;
const double _kMaxPrice = 2000;
const double _kDefaultMinRating = 4.0;
const double _kMinRating = 3.0;
const double _kMaxRating = 5.0;

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initialMaxPrice,
    required this.initialMinRating,
  });

  final double initialMaxPrice;
  final double initialMinRating;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late double _maxPrice = widget.initialMaxPrice;
  late double _minRating = widget.initialMinRating;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.vehicleFilterTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _maxPrice = _kDefaultMaxPrice;
                  _minRating = _kDefaultMinRating;
                }),
                child: Text(
                  l10n.commonReset,
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.vehicleFilterMaxPrice,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                '${_maxPrice.toInt()}K VNĐ',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark,
                ),
              ),
            ],
          ),
          Slider(
            value: _maxPrice,
            min: _kMinPrice,
            max: _kMaxPrice,
            divisions: 17,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.border,
            onChanged: (v) => setState(() => _maxPrice = v),
          ),
          const SizedBox(height: 8),
          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.vehicleFilterMinRating,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),
              Row(
                children: [
                  const Text(
                    '★ ',
                    style: TextStyle(
                      color: AppColors.starYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _minRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Slider(
            value: _minRating,
            min: _kMinRating,
            max: _kMaxRating,
            divisions: 20,
            activeColor: AppColors.starYellow,
            inactiveColor: AppColors.border,
            onChanged: (v) => setState(() => _minRating = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, (
                maxPrice: _maxPrice,
                minRating: _minRating,
              )),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.commonApply,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
