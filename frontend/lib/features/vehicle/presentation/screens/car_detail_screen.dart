import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/screens/booking_screen.dart';

String _formatPrice(double value) {
  final whole = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write('.');
    buffer.write(whole[i]);
  }
  return buffer.toString();
}

class CarDetailScreen extends StatelessWidget {
  const CarDetailScreen({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            _DetailAppBar(vehicle: vehicle),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      vehicle.type.label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (vehicle.isElectric)
                          const _Tag(label: '⚡ Xe điện', color: AppColors.teal),
                        if (vehicle.deliveryAvailable)
                          const _Tag(
                            label: '🚚 Giao xe tận nơi',
                            color: AppColors.primary,
                          ),
                        _Tag(
                          label: vehicle.isAvailable ? 'Còn trống' : 'Đã thuê',
                          color: vehicle.isAvailable
                              ? AppColors.teal
                              : AppColors.mutedText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _PriceCard(pricePerHour: vehicle.pricePerHour),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _BookingBar(vehicle: vehicle),
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFF003380),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Center(
            child: Text(
              vehicle.type.emoji,
              style: const TextStyle(fontSize: 96),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.pricePerHour});

  final double pricePerHour;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${_formatPrice(pricePerHour)}đ',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1,
            ),
          ),
          const SizedBox(width: 4),
          const Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Text(
              '/giờ',
              style: TextStyle(fontSize: 13, color: AppColors.mutedText),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingBar extends StatelessWidget {
  const _BookingBar({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: vehicle.isAvailable
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(vehicle: vehicle),
                    ),
                  )
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            vehicle.isAvailable ? 'Đặt xe' : 'Xe đã được thuê',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
