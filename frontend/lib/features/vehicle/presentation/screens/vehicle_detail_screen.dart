import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/chat/presentation/cubit/start_conversation_cubit.dart';
import 'package:frontend/features/review/presentation/widgets/user_reviews_section.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
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
              onImageChanged: (i) => setState(() => _selectedImageIndex = i),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge strip
                  _BadgeStrip(vehicle: v),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TitleSection(vehicle: v),
                        const SizedBox(height: 20),
                        _SpecsGrid(vehicle: v),
                        const SizedBox(height: 20),
                        _OwnerCard(vehicle: v),
                        const SizedBox(height: 20),
                        UserReviewsSection(
                          userId: v.ownerId,
                          userName: v.ownerName,
                        ),
                        const _TripRulesCard(),
                        const SizedBox(height: 20),
                        _PickupMapBlock(city: v.city),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _BottomBar(vehicle: v),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Hero app bar — 260px, frosted glass buttons
// ─────────────────────────────────────────────

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
    final top = MediaQuery.of(context).padding.top;
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.surface,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Hero image area
            Container(
              width: double.infinity,
              height: double.infinity,
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
            // Back button — frosted glass
            Positioned(
              top: top + 8,
              left: 12,
              child: _GlassCircleButton(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.darkText,
                  size: 20,
                ),
              ),
            ),
            // Heart + share — frosted glass
            Positioned(
              top: top + 8,
              right: 12,
              child: Row(
                children: [
                  _GlassCircleButton(
                    onTap: onFavoriteToggle,
                    child: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? AppColors.danger : AppColors.darkText,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _GlassCircleButton(
                    onTap: () {},
                    child: const Icon(
                      Icons.share_outlined,
                      color: AppColors.darkText,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Gallery counter pill "1 / 3"
            Positioned(
              bottom: 14,
              right: 14,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${selectedIndex + 1} / 3',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(210),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadowColor,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Badge strip — Đặt nhanh / Xe điện / −15%
// ─────────────────────────────────────────────

class _BadgeStrip extends StatelessWidget {
  const _BadgeStrip({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _Badge(
            label: '⚡ Đặt nhanh',
            bg: AppColors.navySoft,
            textColor: AppColors.primary,
          ),
          if (vehicle.isElectric)
            _Badge(
              label: '🔋 Xe điện',
              bg: AppColors.tealSoft,
              textColor: AppColors.tealDark,
            ),
          _Badge(
            label: '🏷 −15% cuối tuần',
            bg: AppColors.warningSoft,
            textColor: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.bg,
    required this.textColor,
  });
  final String label;
  final Color bg;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Title + rating row
// ─────────────────────────────────────────────

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name + price
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                vehicle.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                  height: 1.2,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_fmtVnd(vehicle.pricePerDay)} VNĐ',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyDark,
                    height: 1,
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
        const SizedBox(height: 6),
        Text(
          vehicle.isElectric
              ? 'Điện · ${vehicle.typeLabel}'
              : vehicle.typeLabel,
          style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
        ),
        const SizedBox(height: 10),
        // Rating + location + status
        Row(
          children: [
            if (vehicle.hasRating) ...[
              RatingStars(rating: vehicle.rating!, size: 14),
              const SizedBox(width: 6),
              Text(
                '${vehicle.rating!.toStringAsFixed(1)} (${vehicle.reviewCount})',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
            ],
            StatusChip(
              label: vehicle.isAvailable ? 'Còn xe' : 'Đã thuê',
              color: vehicle.isAvailable
                  ? AppColors.success
                  : AppColors.mutedText,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 14,
              color: AppColors.mutedText,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                vehicle.city ??
                    (vehicle.location.isNotEmpty
                        ? vehicle.location
                        : 'Chưa cập nhật vị trí'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Specs grid — 4 cols
// ─────────────────────────────────────────────

class _SpecsGrid extends StatelessWidget {
  const _SpecsGrid({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    // Chỉ hiển thị thông số có dữ liệu thật; nhiên liệu suy từ isElectric.
    final specs = <_SpecItem>[
      if (vehicle.seats != null)
        _SpecItem(icon: '🪑', label: '${vehicle.seats} chỗ'),
      if (vehicle.transmissionLabel != null)
        _SpecItem(icon: '⚙️', label: vehicle.transmissionLabel!),
      _SpecItem(
        icon: vehicle.isElectric ? '⚡' : '⛽',
        label: vehicle.isElectric ? 'Điện' : 'Xăng',
      ),
      if (vehicle.doors != null)
        _SpecItem(icon: '🚪', label: '${vehicle.doors} cửa'),
    ];

    return Row(
      children: specs.map((s) => Expanded(child: _SpecCard(spec: s))).toList(),
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
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
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

// ─────────────────────────────────────────────
// Owner card — avatar + verified teal badge
// ─────────────────────────────────────────────

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Avatar + verified badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.navySoft,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 24)),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.ownerName ?? 'Chủ xe',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                const Row(
                  children: [
                    Text(
                      '⭐ 4.9',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        ' · 36 chuyến · Phản hồi nhanh',
                        style: TextStyle(
                          fontSize: 12,
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
          // Message button
          _MessageOwnerButton(vehicle: vehicle),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Nút "Nhắn tin" — tạo/lấy hội thoại với chủ xe rồi mở màn chat.
// Ẩn khi người dùng đang xem chính xe của mình.
// ─────────────────────────────────────────────

class _MessageOwnerButton extends StatelessWidget {
  const _MessageOwnerButton({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthCubit>().state.user?.id;
    if (currentUserId != null && currentUserId == vehicle.ownerId) {
      return const SizedBox.shrink();
    }
    return BlocProvider<StartConversationCubit>(
      create: (_) => sl<StartConversationCubit>(),
      child: _MessageOwnerButtonView(vehicle: vehicle),
    );
  }
}

class _MessageOwnerButtonView extends StatelessWidget {
  const _MessageOwnerButtonView({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StartConversationCubit, StartConversationState>(
      listener: (context, state) {
        switch (state) {
          case StartConversationReady(:final conversationId):
            context.push(
              '/chat/$conversationId',
              extra: vehicle.ownerName ?? 'Chủ xe',
            );
          case StartConversationError(:final message):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          case StartConversationIdle():
          case StartConversationInProgress():
        }
      },
      builder: (context, state) {
        final isLoading = state is StartConversationInProgress;
        return OutlinedButton(
          onPressed: isLoading
              ? null
              : () => context.read<StartConversationCubit>().open(
                  participantId: vehicle.ownerId,
                ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : const Text(
                  'Nhắn tin',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Trip rules — teal check icons
// ─────────────────────────────────────────────

class _TripRulesCard extends StatelessWidget {
  const _TripRulesCard();

  static const _rules = [
    'Không hút thuốc trong xe',
    'Không chở hàng hoá cồng kềnh',
    'Trả xe đúng giờ, đúng địa điểm',
    'Vệ sinh xe trước khi trả',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quy định chuyến đi'),
          const SizedBox(height: 12),
          ..._rules.map((r) => _RuleItem(rule: r)),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem({required this.rule});
  final String rule;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.tealSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 11,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rule,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Pickup map block — styled placeholder
// ─────────────────────────────────────────────

class _PickupMapBlock extends StatelessWidget {
  const _PickupMapBlock({this.city});

  final String? city;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Địa điểm nhận xe'),
        const SizedBox(height: 10),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surfaceSunken,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              // Grid lines for map feel
              CustomPaint(
                painter: _MapGridPainter(),
                child: const SizedBox.expand(),
              ),
              // Location pin
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.brandShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            city ?? 'Chưa cập nhật',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withAlpha(120)
      ..strokeWidth = 1;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// Sticky CTA footer — backdrop blur
// ─────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(230),
            border: const Border(top: BorderSide(color: AppColors.inkLight)),
          ),
          child: Row(
            children: [
              // Price block
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_fmtVnd(vehicle.pricePerDay)} VNĐ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDark,
                      height: 1,
                    ),
                  ),
                  const Text(
                    '/ngày',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // CTA button
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.push('/booking/dates', extra: vehicle),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Đặt xe ngay',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
