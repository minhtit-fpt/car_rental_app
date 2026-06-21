import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/search/search_session.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/favorite/presentation/cubit/favorite_cubit.dart';
import 'package:frontend/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_cubit.dart';
import 'package:frontend/features/vehicle/presentation/widgets/car_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onCarsTap});

  final VoidCallback onCarsTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCity = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  final _cities = const ['TP. HCM', 'Hà Nội', 'Đà Nẵng', 'Nha Trang', 'Đà Lạt'];
  // Toạ độ tâm mỗi thành phố (cùng thứ tự với [_cities]) để lọc xe quanh đó.
  static const _cityCoords = [
    (lat: 10.7769, lng: 106.7009), // TP. HCM
    (lat: 21.0278, lng: 105.8342), // Hà Nội
    (lat: 16.0544, lng: 108.2022), // Đà Nẵng
    (lat: 12.2388, lng: 109.1967), // Nha Trang
    (lat: 11.9404, lng: 108.4583), // Đà Lạt
  ];
  final _search = sl<SearchSession>();

  @override
  void initState() {
    super.initState();
    // Khôi phục ngày đã chọn lần tìm trước (nếu có) khi quay lại màn chính.
    _startDate = _search.startDate;
    _endDate = _search.endDate;
  }

  Future<void> _pickCity() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          _CityPickerSheet(cities: _cities, selected: _selectedCity),
    );
    if (picked != null && mounted) {
      setState(() => _selectedCity = picked);
    }
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: (_startDate != null && _endDate != null)
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (range != null && mounted) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
      // Lưu lại để luồng đặt xe prefill theo ngày người dùng vừa chọn.
      _search.setDates(range.start, range.end);
    }
  }

  void _onSearch() {
    // Lọc xe theo thành phố đã chọn: tải xe quanh tâm thành phố (endpoint
    // /nearby), rồi chuyển sang tab "Xe" để xem kết quả. Ngày đã lưu ở
    // SearchSession để prefill khi đặt xe.
    final city = _cityCoords[_selectedCity];
    context.read<VehicleListCubit>().loadNearby(lat: city.lat, lng: city.lng);
    widget.onCarsTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TopBar(),
                  _GreetingHeader(),
                  const SizedBox(height: 16),
                  _SearchCard(
                    cityLabel: _cities[_selectedCity],
                    startDate: _startDate,
                    endDate: _endDate,
                    onTapLocation: _pickCity,
                    onTapDates: _pickDates,
                    onSearch: _onSearch,
                  ),
                  const SizedBox(height: 20),
                  _CityChips(
                    cities: _cities,
                    selected: _selectedCity,
                    onSelect: (i) {
                      setState(() => _selectedCity = i);
                      final c = _cityCoords[i];
                      context.read<VehicleListCubit>().loadNearby(
                        lat: c.lat,
                        lng: c.lng,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _FeaturedCarsSection(onSeeAllTap: widget.onCarsTap),
                  const SizedBox(height: 16),
                  const _TrustBanner(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Top Bar — logo + actions
// ─────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16, top + 8, 16, 8),
      child: Row(
        children: [
          // Logo
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
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          const _NotificationBell(),
        ],
      ),
    );
  }
}

/// Chuông thông báo: mở danh sách `/notifications` và hiển thị badge số chưa
/// đọc. Tự tạo [NotificationCubit] (factory trong DI) và nạp khi dựng; nạp lại
/// sau khi quay về để badge phản ánh các mục vừa đọc.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationCubit>(
      create: (_) => sl<NotificationCubit>()..load(),
      child: const _NotificationBellView(),
    );
  }
}

class _NotificationBellView extends StatelessWidget {
  const _NotificationBellView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final unread = state is NotificationLoaded ? state.data.unreadCount : 0;
        return _NavIconButton(
          icon: Icons.notifications_outlined,
          badgeCount: unread,
          onTap: () async {
            await context.push('/notifications');
            if (context.mounted) {
              context.read<NotificationCubit>().load();
            }
          },
        );
      },
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceSunken,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.darkText),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: _UnreadBadge(count: badgeCount),
            ),
        ],
      ),
    );
  }
}

/// Chấm đỏ kèm số chưa đọc (hiển thị "9+" khi vượt 9). Viền trắng để tách
/// khỏi nền surface phía sau.
class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 9 ? '9+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.surface, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Greeting Header
// ─────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Xin chào, bạn',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.mutedText,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Hôm nay bạn đi đâu?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              letterSpacing: -0.02 * 26,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Search Card
// ─────────────────────────────────────────────

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.cityLabel,
    required this.startDate,
    required this.endDate,
    required this.onTapLocation,
    required this.onTapDates,
    required this.onSearch,
  });

  final String cityLabel;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onTapLocation;
  final VoidCallback onTapDates;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
        child: Column(
          children: [
            // Location row
            InkWell(
              onTap: onTapLocation,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ĐIỂM NHẬN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mutedText,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            cityLabel,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.mutedText,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.inkLight),
            // Date row
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'NHẬN XE',
                    value: startDate == null
                        ? 'Chọn ngày'
                        : _fmtSearchDate(startDate!),
                    borderRight: true,
                    onTap: onTapDates,
                  ),
                ),
                Expanded(
                  child: _DateField(
                    label: 'TRẢ XE',
                    value: endDate == null
                        ? 'Chọn ngày'
                        : _fmtSearchDate(endDate!),
                    borderRight: false,
                    onTap: onTapDates,
                  ),
                ),
              ],
            ),
            // Search button
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onSearch,
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Tìm xe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Định dạng ngày ngắn cho thanh tìm kiếm, ví dụ "T2, 15/06".
String _fmtSearchDate(DateTime d) {
  const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '${weekdays[d.weekday - 1]}, $dd/$mm';
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.borderRight,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool borderRight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: borderRight
              ? const Border(right: BorderSide(color: AppColors.inkLight))
              : null,
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// City Picker (bottom sheet)
// ─────────────────────────────────────────────

class _CityPickerSheet extends StatelessWidget {
  const _CityPickerSheet({required this.cities, required this.selected});

  final List<String> cities;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chọn điểm nhận xe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < cities.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.location_on_outlined,
                  color: i == selected
                      ? AppColors.primary
                      : AppColors.mutedText,
                ),
                title: Text(
                  cities[i],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: i == selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
                trailing: i == selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.primary,
                        size: 20,
                      )
                    : null,
                onTap: () => Navigator.pop(context, i),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// City Chips
// ─────────────────────────────────────────────

class _CityChips extends StatelessWidget {
  const _CityChips({
    required this.cities,
    required this.selected,
    required this.onSelect,
  });

  final List<String> cities;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Khám phá theo thành phố',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: cities.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final active = i == selected;
              return GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: active ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cities[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppColors.darkText,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Featured Cars Section
// ─────────────────────────────────────────────

class _FeaturedCarsSection extends StatelessWidget {
  const _FeaturedCarsSection({required this.onSeeAllTap});

  final VoidCallback onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VehicleListCubit>().state;
    final favorites = context.watch<FavoriteCubit>().state;
    final cars = switch (state) {
      VehicleListLoaded(:final vehicles) => vehicles.take(3).toList(),
      _ => const <Vehicle>[],
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Xe nổi bật gần bạn',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              GestureDetector(
                onTap: onSeeAllTap,
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Danh sách rút gọn — phụ thuộc trạng thái tải xe từ backend.
          switch (state) {
            VehicleListLoading() => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            VehicleListError() => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Không tải được xe nổi bật',
                style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
              ),
            ),
            VehicleListLoaded() => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cars.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final v = cars[index];
                return CarListTile(
                  vehicle: v,
                  isFavorite: favorites.isFavorite(v.id),
                  onFavoriteToggle: () async {
                    final ok = await context.read<FavoriteCubit>().toggle(v);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Không cập nhật được yêu thích, thử lại sau',
                          ),
                        ),
                      );
                    }
                  },
                  onTap: () => context.push('/vehicles/${v.id}', extra: v),
                );
              },
            ),
          },
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Trust / Insurance Banner
// ─────────────────────────────────────────────

class _TrustBanner extends StatelessWidget {
  const _TrustBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.brandShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mỗi chuyến đều có bảo hiểm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Đền bù tối đa 200 triệu cho mọi hư hỏng phát sinh.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
