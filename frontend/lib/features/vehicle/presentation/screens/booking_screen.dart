import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';

enum _BookingStep { details, payment, confirm }

class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    required this.vehicle,
    this.pickupDate,
    this.returnDate,
  });

  final Vehicle vehicle;
  final DateTime? pickupDate;
  final DateTime? returnDate;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  _BookingStep _currentStep = _BookingStep.details;

  late DateTime? _pickupDate;
  late DateTime? _returnDate;
  String _pickupTime = '10:00 AM';
  String _returnTime = '10:00 AM';
  final _pickupLocationCtrl = TextEditingController();
  final _dropoffLocationCtrl = TextEditingController(text: 'Same as pickup');

  @override
  void initState() {
    super.initState();
    _pickupDate = widget.pickupDate;
    _returnDate = widget.returnDate;
  }

  @override
  void dispose() {
    _pickupLocationCtrl.dispose();
    _dropoffLocationCtrl.dispose();
    super.dispose();
  }

  int get _days {
    if (_pickupDate == null || _returnDate == null) return 3;
    return _returnDate!.difference(_pickupDate!).inDays.clamp(1, 365);
  }

  double get _subtotal => widget.vehicle.pricePerDay * _days;
  double get _serviceFee => (_subtotal * 0.04).ceilToDouble();
  static const double _insurance = 15;
  double get _total => _subtotal + _serviceFee + _insurance;

  String _fmtDate(DateTime? d) {
    if (d == null) return 'Select date';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }

  Future<void> _pickDate({required bool isPickup}) async {
    final now = DateTime.now();
    final initial = isPickup
        ? (_pickupDate ?? now)
        : (_returnDate ??
            (_pickupDate?.add(const Duration(days: 1)) ??
                now.add(const Duration(days: 1))));

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

  Future<void> _pickTime({required bool isPickup}) async {
    final parts = (isPickup ? _pickupTime : _returnTime).split(':');
    final hour = int.tryParse(parts[0]) ?? 10;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted = picked.format(context);
      setState(() {
        if (isPickup) {
          _pickupTime = formatted;
        } else {
          _returnTime = formatted;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Complete Your Booking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.darkText,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // Progress stepper
          _BookingProgressBar(currentStep: _currentStep),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking summary mini card
                  _BookingSummaryCard(
                    vehicle: widget.vehicle,
                    days: _days,
                    subtotal: _subtotal,
                    serviceFee: _serviceFee,
                    insurance: _insurance,
                    total: _total,
                  ),
                  const SizedBox(height: 16),
                  // Trip details form
                  _TripDetailsForm(
                    pickupDate: _pickupDate,
                    returnDate: _returnDate,
                    pickupTime: _pickupTime,
                    returnTime: _returnTime,
                    pickupLocationCtrl: _pickupLocationCtrl,
                    dropoffLocationCtrl: _dropoffLocationCtrl,
                    fmtDate: _fmtDate,
                    onPickupDateTap: () => _pickDate(isPickup: true),
                    onReturnDateTap: () => _pickDate(isPickup: false),
                    onPickupTimeTap: () => _pickTime(isPickup: true),
                    onReturnTimeTap: () => _pickTime(isPickup: false),
                  ),
                  const SizedBox(height: 16),
                  // Insurance notice
                  _InsuranceNotice(),
                  const SizedBox(height: 24),
                  // CTA
                  _ContinueButton(
                    onPressed: () => _onContinue(context),
                    label: _currentStep == _BookingStep.details
                        ? 'Continue to Payment →'
                        : _currentStep == _BookingStep.payment
                            ? 'Confirm Booking →'
                            : 'Done',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onContinue(BuildContext context) {
    if (_currentStep == _BookingStep.details) {
      setState(() => _currentStep = _BookingStep.payment);
    } else if (_currentStep == _BookingStep.payment) {
      setState(() => _currentStep = _BookingStep.confirm);
      _showConfirmDialog(context);
    }
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BookingSuccessDialog(
        vehicle: widget.vehicle,
        total: _total,
        onDone: () {
          Navigator.pop(context); // close dialog
          Navigator.pop(context); // back to detail
          Navigator.pop(context); // back to list
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Progress Bar
// ─────────────────────────────────────────────

class _BookingProgressBar extends StatelessWidget {
  const _BookingProgressBar({required this.currentStep});

  final _BookingStep currentStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          _StepDot(
            label: 'Details',
            number: '1',
            isActive: currentStep == _BookingStep.details,
            isDone: currentStep.index > 0,
          ),
          _StepLine(isActive: currentStep.index >= 1),
          _StepDot(
            label: 'Payment',
            number: '2',
            isActive: currentStep == _BookingStep.payment,
            isDone: currentStep.index > 1,
          ),
          _StepLine(isActive: currentStep.index >= 2),
          _StepDot(
            label: 'Confirm',
            number: '3',
            isActive: currentStep == _BookingStep.confirm,
            isDone: false,
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.label,
    required this.number,
    required this.isActive,
    required this.isDone,
  });

  final String label;
  final String number;
  final bool isActive;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final color = isActive || isDone ? AppColors.primary : AppColors.border;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppColors.primary : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14)
                : Text(
                    number,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? AppColors.primary : AppColors.mutedText,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppColors.darkText : AppColors.mutedText,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? AppColors.primary : AppColors.border,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Booking Summary Card
// ─────────────────────────────────────────────

class _BookingSummaryCard extends StatelessWidget {
  const _BookingSummaryCard({
    required this.vehicle,
    required this.days,
    required this.subtotal,
    required this.serviceFee,
    required this.insurance,
    required this.total,
  });

  final Vehicle vehicle;
  final int days;
  final double subtotal;
  final double serviceFee;
  final double insurance;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Booking Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 14),
          // Car info
          Row(
            children: [
              Container(
                width: 60,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.cardImageGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(vehicle.emoji,
                      style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${vehicle.year} · ${vehicle.isElectric ? 'Electric' : vehicle.type}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.mutedText),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          _SummaryRow(
            label: '$days day${days > 1 ? 's' : ''} × \$${vehicle.pricePerDay.toStringAsFixed(0)}',
            value: '\$${subtotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Service fee',
            value: '\$${serviceFee.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Insurance',
            value: '\$${insurance.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.secondaryText)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Trip Details Form
// ─────────────────────────────────────────────

class _TripDetailsForm extends StatelessWidget {
  const _TripDetailsForm({
    required this.pickupDate,
    required this.returnDate,
    required this.pickupTime,
    required this.returnTime,
    required this.pickupLocationCtrl,
    required this.dropoffLocationCtrl,
    required this.fmtDate,
    required this.onPickupDateTap,
    required this.onReturnDateTap,
    required this.onPickupTimeTap,
    required this.onReturnTimeTap,
  });

  final DateTime? pickupDate;
  final DateTime? returnDate;
  final String pickupTime;
  final String returnTime;
  final TextEditingController pickupLocationCtrl;
  final TextEditingController dropoffLocationCtrl;
  final String Function(DateTime?) fmtDate;
  final VoidCallback onPickupDateTap;
  final VoidCallback onReturnDateTap;
  final VoidCallback onPickupTimeTap;
  final VoidCallback onReturnTimeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Trip Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          // Row 1: Pickup Date + Pickup Time
          Row(
            children: [
              Expanded(
                child: _FormField(
                  label: 'Pickup Date',
                  prefix: '📅',
                  value: fmtDate(pickupDate),
                  onTap: onPickupDateTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormField(
                  label: 'Pickup Time',
                  prefix: '🕐',
                  value: pickupTime,
                  onTap: onPickupTimeTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Row 2: Return Date + Return Time
          Row(
            children: [
              Expanded(
                child: _FormField(
                  label: 'Return Date',
                  prefix: '📅',
                  value: fmtDate(returnDate),
                  onTap: onReturnDateTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormField(
                  label: 'Return Time',
                  prefix: '🕐',
                  value: returnTime,
                  onTap: onReturnTimeTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Pickup Location
          _TextInputField(
            label: 'Pickup Location',
            prefix: '📍',
            hint: 'Enter pickup address',
            controller: pickupLocationCtrl,
          ),
          const SizedBox(height: 14),
          // Drop-off Location
          _TextInputField(
            label: 'Drop-off Location',
            prefix: '📍',
            hint: 'Same as pickup',
            controller: dropoffLocationCtrl,
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.prefix,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String prefix;
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Row(
              children: [
                Text(prefix),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: value == 'Select date'
                          ? AppColors.mutedText
                          : AppColors.darkText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextInputField extends StatelessWidget {
  const _TextInputField({
    required this.label,
    required this.prefix,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String prefix;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13, color: AppColors.darkText),
            decoration: InputDecoration(
              prefixText: '$prefix  ',
              prefixStyle: const TextStyle(fontSize: 13),
              hintText: hint,
              hintStyle: const TextStyle(
                  fontSize: 12, color: AppColors.mutedText),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Insurance Notice
// ─────────────────────────────────────────────

class _InsuranceNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: const Row(
        children: [
          Text('🛡️', style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Basic insurance included. Upgrade available.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF166534),
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
// Continue Button
// ─────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: AppColors.primary.withAlpha(51),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Booking Success Dialog
// ─────────────────────────────────────────────

class _BookingSuccessDialog extends StatelessWidget {
  const _BookingSuccessDialog({
    required this.vehicle,
    required this.total,
    required this.onDone,
  });

  final Vehicle vehicle;
  final double total;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                gradient: AppColors.promoGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${vehicle.name} is booked.\nTotal charged: \$${total.toStringAsFixed(0)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Back to Home',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
