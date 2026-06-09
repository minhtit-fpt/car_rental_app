import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/features/vehicle/presentation/screens/booking_screen.dart';

class CarDetailScreen extends StatefulWidget {
  const CarDetailScreen({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  DateTime? _pickupDate;
  DateTime? _returnDate;

  int get _days {
    if (_pickupDate == null || _returnDate == null) return 1;
    return _returnDate!.difference(_pickupDate!).inDays.clamp(1, 365);
  }

  double get _subtotal => widget.vehicle.pricePerDay * _days;
  double get _serviceFee => (_subtotal * 0.04).roundToDouble();
  double get _insurance => 15;
  double get _total => _subtotal + _serviceFee + _insurance;

  Future<void> _pickDate({required bool isPickup}) async {
    final now = DateTime.now();
    final initial = isPickup
        ? (_pickupDate ?? now)
        : (_returnDate ?? (_pickupDate?.add(const Duration(days: 1)) ?? now.add(const Duration(days: 1))));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isPickup) {
          _pickupDate = picked;
          if (_returnDate != null && !_returnDate!.isAfter(picked)) {
            _returnDate = picked.add(const Duration(days: 1));
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _GallerySliverAppBar(vehicle: v),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CarHeaderSection(vehicle: v),
                      const SizedBox(height: 4),
                      _FeatureTags(vehicle: v),
                      const SizedBox(height: 16),
                      _SpecificationsCard(vehicle: v),
                      const SizedBox(height: 16),
                      _AboutCard(vehicle: v),
                      // Bottom padding so sticky bar doesn't cover content
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
            // Sticky bottom pricing bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _StickyPricingBar(
                vehicle: v,
                pickupDate: _pickupDate,
                returnDate: _returnDate,
                days: _days,
                total: _total,
                onPickupTap: () => _pickDate(isPickup: true),
                onReturnTap: () => _pickDate(isPickup: false),
                onRentNow: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(
                      vehicle: v,
                      pickupDate: _pickupDate,
                      returnDate: _returnDate,
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

// ─────────────────────────────────────────────
// Gallery SliverAppBar
// ─────────────────────────────────────────────

class _GallerySliverAppBar extends StatelessWidget {
  const _GallerySliverAppBar({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.darkText,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.white.withAlpha(230),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.darkText, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CircleAvatar(
            backgroundColor: Colors.white.withAlpha(230),
            child: IconButton(
              icon: const Icon(Icons.favorite_border_rounded,
                  color: AppColors.darkText, size: 20),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _GalleryGrid(vehicle: vehicle),
      ),
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  const _GalleryGrid({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Main large photo
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withAlpha(20),
                  AppColors.teal.withAlpha(10),
                ],
              ),
            ),
            child: Center(
              child: Text(vehicle.emoji,
                  style: const TextStyle(fontSize: 96)),
            ),
          ),
        ),
        const SizedBox(width: 2),
        // Side thumbnails
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withAlpha(15),
                        AppColors.teal.withAlpha(8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(vehicle.emoji,
                        style: const TextStyle(fontSize: 36)),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withAlpha(10),
                            AppColors.teal.withAlpha(15),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(vehicle.emoji,
                            style: const TextStyle(fontSize: 36)),
                      ),
                    ),
                    Container(color: Colors.black.withAlpha(102)),
                    const Center(
                      child: Text(
                        '+6 photos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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

// ─────────────────────────────────────────────
// Car Header Section
// ─────────────────────────────────────────────

class _CarHeaderSection extends StatelessWidget {
  const _CarHeaderSection({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  vehicle.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Superhost badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4AA), Color(0xFF00B894)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '★ Superhost',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '★ ${vehicle.rating} (${vehicle.reviewCount} reviews) · ${vehicle.reviewCount ~/ 2} trips · Hosted by ${vehicle.ownerName}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Feature Tags (Autopilot, Premium Audio, etc.)
// ─────────────────────────────────────────────

class _FeatureTags extends StatelessWidget {
  const _FeatureTags({required this.vehicle});

  final Vehicle vehicle;

  List<String> get _tags {
    final base = <String>[];
    if (vehicle.isElectric) base.addAll(['Electric', 'Zero Emission']);
    if (vehicle.type == 'SUV') base.add('4WD');
    base.addAll(['Premium Audio', 'Bluetooth', 'USB Charging']);
    return base.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _tags
            .map(
              (tag) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Specifications Card
// ─────────────────────────────────────────────

class _SpecificationsCard extends StatelessWidget {
  const _SpecificationsCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final specs = [
      ('Year', '${vehicle.year}'),
      ('Seats', '5'),
      ('Transmission', 'Auto'),
      ('Fuel Type', vehicle.isElectric ? 'Electric' : 'Gasoline'),
      if (vehicle.isElectric) ('Range', '358 mi'),
      ('Brand', vehicle.name.split(' ').first),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Text(
                'Specifications',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ),
            ...specs.asMap().entries.map((entry) {
              final isLast = entry.key == specs.length - 1;
              final spec = entry.value;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      spec.$1,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      spec.$2,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// About Card
// ─────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final desc =
        'Experience the ${vehicle.name} — a premium ${vehicle.isElectric ? 'electric' : ''} car. '
        'This ${vehicle.year} model is perfect for city drives and weekend getaways, '
        'maintained in excellent condition by our verified host.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About This Car',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sticky Pricing Bottom Bar
// ─────────────────────────────────────────────

class _StickyPricingBar extends StatelessWidget {
  const _StickyPricingBar({
    required this.vehicle,
    required this.pickupDate,
    required this.returnDate,
    required this.days,
    required this.total,
    required this.onPickupTap,
    required this.onReturnTap,
    required this.onRentNow,
  });

  final Vehicle vehicle;
  final DateTime? pickupDate;
  final DateTime? returnDate;
  final int days;
  final double total;
  final VoidCallback onPickupTap;
  final VoidCallback onReturnTap;
  final VoidCallback onRentNow;

  String _fmt(DateTime? d) {
    if (d == null) return 'Select date';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date pickers row
          Row(
            children: [
              Expanded(
                child: _DatePickerField(
                  label: '📅 Pickup',
                  value: _fmt(pickupDate),
                  onTap: onPickupTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DatePickerField(
                  label: '📅 Return',
                  value: _fmt(returnDate),
                  onTap: onReturnTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Price + button row
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${vehicle.pricePerDay.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          height: 1,
                        ),
                      ),
                      const Text(
                        '/day',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Total: \$${total.toStringAsFixed(0)} · $days day${days > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onRentNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    elevation: 0,
                    shadowColor: AppColors.primary.withAlpha(51),
                  ),
                  child: const Text(
                    'Rent Now',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Free cancellation up to 24h before pickup',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: value == 'Select date'
                    ? AppColors.mutedText
                    : AppColors.darkText,
                fontWeight: value == 'Select date'
                    ? FontWeight.normal
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
