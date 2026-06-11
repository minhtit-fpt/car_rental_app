import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

String _formatPrice(double value) {
  // Hiển thị gọn: 120000 -> "120.000".
  final whole = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write('.');
    buffer.write(whole[i]);
  }
  return buffer.toString();
}

class _EvBadge extends StatelessWidget {
  const _EvBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _PriceText extends StatelessWidget {
  const _PriceText(this.pricePerHour);

  final double pricePerHour;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${_formatPrice(pricePerHour)}đ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            height: 1,
          ),
        ),
        const SizedBox(width: 3),
        const Padding(
          padding: EdgeInsets.only(bottom: 1),
          child: Text(
            '/giờ',
            style: TextStyle(fontSize: 11, color: AppColors.mutedText),
          ),
        ),
      ],
    );
  }
}

/// Card dọc — dùng cho khu "Featured" ở Home.
class CarCard extends StatelessWidget {
  const CarCard({
    super.key,
    required this.vehicle,
    this.onTap,
    this.width,
  });

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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadowColor,
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
            Container(
              height: 150,
              decoration: const BoxDecoration(
                gradient: AppColors.cardImageGradient,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      vehicle.type.emoji,
                      style: const TextStyle(fontSize: 62),
                    ),
                  ),
                  if (vehicle.isElectric)
                    const Positioned(top: 10, right: 10, child: _EvBadge()),
                  if (!vehicle.isAvailable)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mutedText,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Đã thuê',
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.type.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PriceText(vehicle.pricePerHour),
                  if (vehicle.deliveryAvailable) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 13,
                          color: AppColors.teal,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Giao xe tận nơi',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card ngang full-width — dùng cho màn danh sách.
class CarListTile extends StatelessWidget {
  const CarListTile({super.key, required this.vehicle, this.onTap});

  final Vehicle vehicle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadowColor,
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            Container(
              width: 120,
              height: 110,
              decoration: const BoxDecoration(
                gradient: AppColors.cardImageGradient,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    vehicle.type.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  if (vehicle.isElectric)
                    const Positioned(bottom: 6, left: 6, child: _EvBadge()),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vehicle.type.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _PriceText(vehicle.pricePerHour),
                        if (!vehicle.isAvailable)
                          const Text(
                            'Đã thuê',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedText,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else if (vehicle.deliveryAvailable)
                          const Icon(
                            Icons.local_shipping_outlined,
                            size: 16,
                            color: AppColors.teal,
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
