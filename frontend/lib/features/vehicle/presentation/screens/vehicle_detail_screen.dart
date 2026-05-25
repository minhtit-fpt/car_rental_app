import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rating_stars.dart';
import 'package:frontend/shared/widgets/section_header.dart';
import 'package:frontend/shared/widgets/status_chip.dart';

// pricePerDay stored in K VNĐ
String _fmtVnd(double kAmount) {
  if (kAmount >= 1000) {
    final m = kAmount / 1000;
    if (m == m.truncateToDouble()) return '${m.truncate()}M';
    return '${m.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '')}M';
  }
  return '${kAmount.toInt()}K';
}

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  bool _isFavorite = false;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            _DetailAppBar(
              vehicle: v,
              isFavorite: _isFavorite,
              selectedIndex: _selectedImageIndex,
              onFavoriteToggle: () =>
                  setState(() => _isFavorite = !_isFavorite),
              onImageChanged: (i) =>
                  setState(() => _selectedImageIndex = i),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TitleSection(vehicle: v),
                    const SizedBox(height: 20),
                    _SpecsRow(vehicle: v),
                    const SizedBox(height: 20),
                    const _DescriptionCard(),
                    const SizedBox(height: 20),
                    _FeaturesCard(vehicle: v),
                    const SizedBox(height: 20),
                    _OwnerCard(vehicle: v),
                    const SizedBox(height: 20),
                    _ReviewsSection(vehicle: v),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _BottomBar(vehicle: v),
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({
    required this.vehicle,
    required this.isFavorite,
    required this.selectedIndex,
    required this.onFavoriteToggle,
    required this.onImageChanged,
  });

  final Vehicle vehicle;
  final bool isFavorite;
  final int selectedIndex;
  final VoidCallback onFavoriteToggle;
  final ValueChanged<int> onImageChanged;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(230),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: onFavoriteToggle,
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface.withAlpha(230),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? const Color(0xFFEF4444) : AppColors.darkText,
              size: 20,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface.withAlpha(230),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_outlined, color: AppColors.darkText, size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.cardImageGradient,
              ),
              child: Center(
                child: Text(
                  vehicle.emoji,
                  style: const TextStyle(fontSize: 100),
                ),
              ),
            ),
            if (vehicle.isElectric)
              Positioned(
                bottom: 40,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '⚡ EV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final active = i == selectedIndex;
                  return GestureDetector(
                    onTap: () => onImageChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.year} · ${vehicle.isElectric ? 'Điện' : vehicle.type}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${_fmtVnd(vehicle.pricePerDay)} VNĐ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '/ngày',
                  style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            RatingStars(rating: vehicle.rating, size: 14),
            const SizedBox(width: 6),
            Text(
              '${vehicle.rating.toStringAsFixed(1)} (${vehicle.reviewCount} đánh giá)',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_rounded,
                size: 14, color: AppColors.mutedText),
            const SizedBox(width: 4),
            Text(
              vehicle.location.isNotEmpty ? vehicle.location : 'Hà Nội',
              style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
            ),
            const SizedBox(width: 12),
            StatusChip(label: 'Còn xe', color: const Color(0xFF10B981)),
          ],
        ),
      ],
    );
  }
}

class _SpecsRow extends StatelessWidget {
  const _SpecsRow({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final specs = [
      _SpecItem(icon: '🪑', label: '5 chỗ'),
      _SpecItem(
        icon: vehicle.isElectric ? '⚡' : '⛽',
        label: vehicle.isElectric ? 'Điện' : 'Xăng',
      ),
      _SpecItem(icon: '🔧', label: 'Tự động'),
      _SpecItem(icon: '📦', label: 'Giao xe'),
    ];

    return Row(
      children: specs
          .map((s) => Expanded(child: _SpecCard(spec: s)))
          .toList(),
    );
  }
}

class _SpecItem {
  const _SpecItem({required this.icon, required this.label});
  final String icon;
  final String label;
}

class _SpecCard extends StatelessWidget {
  const _SpecCard({required this.spec});
  final _SpecItem spec;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(spec.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            spec.label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatefulWidget {
  const _DescriptionCard();

  @override
  State<_DescriptionCard> createState() => _DescriptionCardState();
}

class _DescriptionCardState extends State<_DescriptionCard> {
  bool _expanded = false;

  static const _full =
      'Xe được bảo dưỡng định kỳ, nội thất sạch sẽ và đầy đủ tiện nghi. '
      'Trang bị camera 360°, cảm biến lùi, màn hình cảm ứng 10", kết nối Apple CarPlay/Android Auto. '
      'Xe có bảo hiểm toàn diện và hỗ trợ đường dài 24/7. '
      'Phù hợp cho gia đình, công tác và du lịch dài ngày.';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const SectionHeader(title: 'Mô tả xe'),
          const SizedBox(height: 10),
          Text(
            _full,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Thu gọn' : 'Xem thêm',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesCard extends StatelessWidget {
  const _FeaturesCard({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final features = [
      ('📷', 'Camera 360°'),
      ('🎵', 'CarPlay / AA'),
      ('❄️', 'Điều hoà tự động'),
      ('🔌', vehicle.isElectric ? 'Sạc nhanh DC' : 'GPS tích hợp'),
      ('🛡️', 'Bảo hiểm toàn diện'),
      ('📦', 'Giao xe tận nơi'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
          const SectionHeader(title: 'Trang bị nổi bật'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: features
                .map((f) => _FeatureChip(icon: f.$1, label: f.$2))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.ownerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '⭐ 4.9 · 36 chuyến · Phản hồi nhanh',
                  style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text(
              'Nhắn tin',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Đánh giá',
          trailing: GestureDetector(
            onTap: () {},
            child: const Text(
              'Xem tất cả',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _ReviewCard(
          name: 'Thanh N.',
          rating: 5,
          date: '12/05/2025',
          comment: 'Xe sạch, đúng giờ, chủ xe nhiệt tình. Sẽ thuê lại!',
        ),
        const SizedBox(height: 10),
        const _ReviewCard(
          name: 'Hùng T.',
          rating: 4,
          date: '03/05/2025',
          comment: 'Xe tốt, điều hoà mát. Giao xe hơi muộn 15 phút nhưng ổn.',
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
  });

  final String name;
  final int rating;
  final String date;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
              RatingStars(rating: rating.toDouble(), size: 12),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_fmtVnd(vehicle.pricePerDay)} VNĐ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                '/ngày',
                style: TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              label: 'Đặt xe ngay',
              onPressed: () => context.push(
                '/booking/dates',
                extra: vehicle,
              ),
              icon: Icons.directions_car_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
