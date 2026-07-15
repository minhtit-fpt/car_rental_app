import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/vehicle_display_l10n.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/utils/price_format.dart';

/// Nút tim tròn nền trắng đặt trên ảnh xe (card / list tile). Bấm để lưu/bỏ.
class _FavoriteHeartButton extends StatelessWidget {
  const _FavoriteHeartButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(230),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: context.palette.cardShadowColor,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 17,
          color: isFavorite ? AppColors.danger : context.palette.secondaryText,
        ),
      ),
    );
  }
}

// pricePerDay is stored in K VNĐ (e.g. 890 = 890K VNĐ)
String _fmtVnd(double kAmount) =>
    formatPricePerDayK(kAmount, withCurrency: true);

class CarCard extends StatelessWidget {
  const CarCard({super.key, required this.vehicle, this.onTap, this.width});

  final Vehicle vehicle;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: context.palette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.palette.border),
          boxShadow: [
            BoxShadow(
              color: context.palette.cardShadowColor,
              blurRadius: 16,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _CardImageArea(vehicle: vehicle),
            _CardDetails(vehicle: vehicle),
          ],
        ),
      ),
    );
  }
}

class _CardImageArea extends StatelessWidget {
  const _CardImageArea({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: const BoxDecoration(gradient: AppColors.cardImageGradient),
      child: Stack(
        children: [
          Center(
            child: Text(vehicle.emoji, style: const TextStyle(fontSize: 62)),
          ),
          if (vehicle.isElectric)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '⚡ EV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardDetails extends StatelessWidget {
  const _CardDetails({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vehicle.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.palette.darkText,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            vehicle.typeSummaryL10n(l10n),
            style: TextStyle(fontSize: 12, color: context.palette.mutedText),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmtVnd(vehicle.pricePerDayK),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyDark,
                  height: 1,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  l10n.vehiclePerDay,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.palette.mutedText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _VehicleMetaRow(vehicle: vehicle),
        ],
      ),
    );
  }
}

/// Dòng thông tin phụ dưới giá: hiện đánh giá thật nếu có, nếu chưa thì hiện
/// trạng thái còn trống + nhãn giao xe (đều là dữ liệu thật từ backend).
class _VehicleMetaRow extends StatelessWidget {
  const _VehicleMetaRow({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (vehicle.hasRating) {
      return Row(
        children: [
          const Text(
            '★',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.starYellow,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            vehicle.rating!.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.starYellow,
            ),
          ),
          if (vehicle.ownerName != null) ...[
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '· ${vehicle.ownerName}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.palette.secondaryText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      );
    }
    return Row(
      children: [
        Icon(
          vehicle.isAvailable
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
          size: 13,
          color: vehicle.isAvailable
              ? AppColors.teal
              : context.palette.mutedText,
        ),
        const SizedBox(width: 4),
        Text(
          vehicle.isAvailable ? l10n.vehicleAvailable : l10n.vehicleRented,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: vehicle.isAvailable
                ? AppColors.teal
                : context.palette.mutedText,
          ),
        ),
        if (vehicle.deliveryAvailable) ...[
          const SizedBox(width: 8),
          const Icon(
            Icons.local_shipping_outlined,
            size: 13,
            color: AppColors.primary,
          ),
          const SizedBox(width: 3),
          Text(
            l10n.vehicleDelivery,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Full-width horizontal card variant for the list screen
class CarListTile extends StatelessWidget {
  const CarListTile({
    super.key,
    required this.vehicle,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  final Vehicle vehicle;
  final VoidCallback? onTap;

  /// Có hiển thị nút tim hay không phụ thuộc [onFavoriteToggle] != null.
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.palette.border),
          boxShadow: [
            BoxShadow(
              color: context.palette.cardShadowColor,
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            // Image
            Container(
              width: 120,
              height: 110,
              decoration: const BoxDecoration(
                gradient: AppColors.cardImageGradient,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(vehicle.emoji, style: const TextStyle(fontSize: 48)),
                  if (onFavoriteToggle != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _FavoriteHeartButton(
                        isFavorite: isFavorite,
                        onTap: onFavoriteToggle!,
                      ),
                    ),
                  if (vehicle.isElectric)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '⚡ EV',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vehicle.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: context.palette.darkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vehicle.typeSummaryL10n(l10n),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.palette.mutedText,
                      ),
                    ),
                    if (vehicle.city != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '📍 ${vehicle.city}',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.palette.mutedText,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _fmtVnd(vehicle.pricePerDayK),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navyDark,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 1),
                              child: Text(
                                l10n.vehiclePerDay,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.palette.mutedText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (vehicle.hasRating)
                          Row(
                            children: [
                              const Text(
                                '★',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.starYellow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${vehicle.rating!.toStringAsFixed(1)} (${vehicle.reviewCount})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.palette.secondaryText,
                                ),
                              ),
                            ],
                          )
                        else if (vehicle.deliveryAvailable)
                          Row(
                            children: [
                              const Icon(
                                Icons.local_shipping_outlined,
                                size: 13,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                l10n.vehicleDelivery,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
