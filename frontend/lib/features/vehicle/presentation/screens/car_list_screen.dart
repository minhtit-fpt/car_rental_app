import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_cubit.dart';
import 'package:frontend/features/vehicle/presentation/widgets/car_card.dart';

enum _QuickFilter { all, instant, auto, electric, five, seven }

const _filterLabels = {
  _QuickFilter.all: 'Tất cả',
  _QuickFilter.instant: '⚡ Đặt nhanh',
  _QuickFilter.auto: '⚙️ Số tự động',
  _QuickFilter.electric: '🔋 Xe điện',
  _QuickFilter.five: '5 chỗ',
  _QuickFilter.seven: '7+ chỗ',
};

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  _QuickFilter _activeFilter = _QuickFilter.all;
  bool _showMap = false;
  String _sortBy = 'Phổ biến nhất';

  /// Lọc trên danh sách đã tải từ backend. Chỉ "Xe điện" có dữ liệu thật để
  /// lọc (isElectric); các chip còn lại chưa ánh xạ được sang trường backend
  /// nên tạm hiển thị tất cả.
  List<Vehicle> _applyFilter(List<Vehicle> all) {
    return switch (_activeFilter) {
      _QuickFilter.electric => all.where((v) => v.isElectric).toList(),
      _ => all,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<VehicleListCubit, VehicleListState>(
        builder: (context, state) {
          final all = switch (state) {
            VehicleListLoaded(:final vehicles) => vehicles,
            _ => const <Vehicle>[],
          };
          final vehicles = _applyFilter(all);
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
                    const Text(
                      'Tìm xe',
                      style: TextStyle(
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
                    onSelected: (f) => setState(() => _activeFilter = f),
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
                        '${vehicles.length} xe phù hợp',
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
              // Danh sách xe — phụ thuộc trạng thái tải từ backend.
              switch (state) {
                VehicleListLoading() => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                VehicleListError(:final message) => SliverFillRemaining(
                  child: _ErrorState(
                    message: message,
                    onRetry: () => context.read<VehicleListCubit>().load(),
                  ),
                ),
                VehicleListLoaded() =>
                  vehicles.isEmpty
                      ? const SliverFillRemaining(child: _EmptyState())
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          sliver: SliverList.separated(
                            itemCount: vehicles.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final v = vehicles[index];
                              return CarListTile(
                                vehicle: v,
                                onTap: () =>
                                    context.push('/vehicles/${v.id}', extra: v),
                              );
                            },
                          ),
                        ),
              },
            ],
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _FilterSheet(),
    );
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
              showMap ? 'Danh sách' : 'Xem bản đồ',
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
                children: const [
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ĐỊA ĐIỂM',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Quận 1, TP. HCM',
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
          Container(width: 1, height: 36, color: AppColors.inkLight),
          // Dates
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 14, 12),
              child: Row(
                children: const [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THỜI GIAN',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
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
                _filterLabels[f]!,
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
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
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
        items: const [
          DropdownMenuItem(
            value: 'Phổ biến nhất',
            child: Text('Phổ biến nhất'),
          ),
          DropdownMenuItem(
            value: 'Giá thấp nhất',
            child: Text('Giá thấp nhất'),
          ),
          DropdownMenuItem(value: 'Đánh giá cao', child: Text('Đánh giá cao')),
          DropdownMenuItem(value: 'Gần nhất', child: Text('Gần nhất')),
        ],
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('🚗', style: TextStyle(fontSize: 56)),
          SizedBox(height: 16),
          Text(
            'Không có xe phù hợp',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Thử thay đổi bộ lọc hoặc tìm kiếm khác',
            style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
          ),
        ],
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
              'Không tải được danh sách xe',
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

// ─────────────────────────────────────────────
// Filter bottom sheet
// ─────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  double _maxPrice = 1500;
  double _minRating = 4.0;

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Bộ lọc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _maxPrice = 1500;
                  _minRating = 4.0;
                }),
                child: const Text(
                  'Đặt lại',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Giá tối đa / ngày',
                style: TextStyle(
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
            min: 300,
            max: 2000,
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
              const Text(
                'Đánh giá tối thiểu',
                style: TextStyle(
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
            min: 3.0,
            max: 5.0,
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
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Áp dụng',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
