import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/owner/presentation/cubit/vehicle_form_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/section_header.dart';
import 'package:frontend/shared/utils/coming_soon.dart';

class AddEditVehicleScreen extends StatefulWidget {
  const AddEditVehicleScreen({super.key, this.isEdit = false, this.vehicle});

  final bool isEdit;

  /// Xe cần sửa (chỉ có khi [isEdit] = true). Dùng để prefill form.
  final Vehicle? vehicle;

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _nameController = TextEditingController(text: '');
  final _priceController = TextEditingController(text: '');
  final _descController = TextEditingController(text: '');
  final _seatsController = TextEditingController(text: '');
  final _doorsController = TextEditingController(text: '');
  final _cityController = TextEditingController(text: '');
  // Vị trí mặc định: trung tâm Hà Nội (chưa có map picker — sẽ thay sau).
  final _latController = TextEditingController(text: '21.0278');
  final _lngController = TextEditingController(text: '105.8342');
  String _selectedType = 'CAR';
  String? _transmission; // 'AUTOMATIC' | 'MANUAL' | null
  bool _isElectric = false;
  bool _deliveryAvailable = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Prefill khi sửa. Vehicle entity không có lat/lng nên giữ nguyên vị trí cũ
    // (card vị trí được ẩn ở chế độ sửa, không gửi toạ độ lên backend).
    final v = widget.vehicle;
    if (v != null) {
      _nameController.text = v.title;
      _priceController.text = v.pricePerHour.toStringAsFixed(0);
      _selectedType = v.type;
      _isElectric = v.isElectric;
      _deliveryAvailable = v.deliveryAvailable;
      _seatsController.text = v.seats?.toString() ?? '';
      _doorsController.text = v.doors?.toString() ?? '';
      _cityController.text = v.city ?? '';
      _transmission = v.transmission;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _seatsController.dispose();
    _doorsController.dispose();
    _cityController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final title = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    if (title.isEmpty) return _snack(l10n.ownerVehicleNameRequired);
    if (price == null || price <= 0) {
      return _snack(l10n.ownerVehiclePriceInvalid);
    }

    final seats = int.tryParse(_seatsController.text.trim());
    final doors = int.tryParse(_doorsController.text.trim());
    final cityText = _cityController.text.trim();
    final city = cityText.isEmpty ? null : cityText;

    final cubit = sl<VehicleFormCubit>();
    setState(() => _isSubmitting = true);

    if (widget.isEdit) {
      // Sửa: không gửi toạ độ (giữ nguyên vị trí cũ); type không đổi được.
      await cubit.update(
        widget.vehicle!.id,
        title: title,
        pricePerHour: price,
        isElectric: _isElectric,
        deliveryAvailable: _deliveryAvailable,
        seats: seats,
        doors: doors,
        transmission: _transmission,
        city: city,
      );
    } else {
      final lat = double.tryParse(_latController.text.trim());
      final lng = double.tryParse(_lngController.text.trim());
      if (lat == null || lng == null) {
        setState(() => _isSubmitting = false);
        return _snack(l10n.ownerVehicleCoordsInvalid);
      }
      await cubit.create(
        type: _selectedType,
        title: title,
        pricePerHour: price,
        isElectric: _isElectric,
        deliveryAvailable: _deliveryAvailable,
        lat: lat,
        lng: lng,
        seats: seats,
        doors: doors,
        transmission: _transmission,
        city: city,
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    switch (cubit.state) {
      case VehicleFormSuccess():
        _snack(
          widget.isEdit
              ? l10n.ownerVehicleUpdateSuccess
              : l10n.ownerVehicleCreateSuccess,
        );
        context.pop(true);
      case VehicleFormError(:final message):
        _snack(message);
      case VehicleFormIdle():
      case VehicleFormSubmitting():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // value gửi server → nhãn hiển thị (đã localize). Mục đầu hộp số = null.
    final transmissions = {
      '': l10n.vehicleTransmissionNone,
      'AUTOMATIC': l10n.vehicleTransmissionAutomatic,
      'MANUAL': l10n.vehicleTransmissionManual,
    };
    final types = {
      'CAR': l10n.vehicleTypeCar,
      'MOTORBIKE': l10n.vehicleTypeMotorbike,
      'BICYCLE': l10n.vehicleTypeBicycle,
    };
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: CustomScrollView(
          slivers: [
            RvSliverAppBar(
              title: widget.isEdit
                  ? l10n.ownerVehicleEditTitle
                  : l10n.ownerVehicleAddTitle,
              subtitle: widget.isEdit
                  ? l10n.ownerVehicleEditSubtitle
                  : l10n.ownerVehicleAddSubtitle,
              role: RvRole.owner,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _PhotoSection(),
                    const SizedBox(height: 20),
                    _BasicInfoCard(
                      nameController: _nameController,
                      priceController: _priceController,
                      selectedType: _selectedType,
                      types: types,
                      onTypeChanged: (t) => setState(() => _selectedType = t),
                    ),
                    const SizedBox(height: 16),
                    _SpecsCard(
                      seatsController: _seatsController,
                      doorsController: _doorsController,
                      cityController: _cityController,
                      transmission: _transmission,
                      transmissions: transmissions,
                      onTransmissionChanged: (t) =>
                          setState(() => _transmission = t.isEmpty ? null : t),
                    ),
                    const SizedBox(height: 16),
                    _DescriptionCard(controller: _descController),
                    // Vị trí chỉ đặt khi đăng xe mới — sửa xe giữ nguyên toạ độ
                    // cũ (Vehicle entity chưa expose lat/lng để prefill).
                    if (!widget.isEdit) ...[
                      const SizedBox(height: 16),
                      _LocationCard(
                        latController: _latController,
                        lngController: _lngController,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _OptionsCard(
                      isElectric: _isElectric,
                      deliveryAvailable: _deliveryAvailable,
                      onElectricChanged: (v) => setState(() => _isElectric = v),
                      onDeliveryChanged: (v) =>
                          setState(() => _deliveryAvailable = v),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: widget.isEdit
                          ? l10n.ownerVehicleSaveChanges
                          : l10n.ownerVehiclePublish,
                      onPressed: _isSubmitting ? null : _submit,
                      isLoading: _isSubmitting,
                      icon: widget.isEdit
                          ? Icons.save_outlined
                          : Icons.upload_rounded,
                    ),
                    const SizedBox(height: 24),
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

class _PhotoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: AppLocalizations.of(context).ownerVehiclePhotos),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _AddPhotoTile(),
                ...List.generate(
                  2,
                  (i) => Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardImageGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        i == 0 ? '🚗' : '🏎️',
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).ownerVehiclePhotosHint,
            style: TextStyle(fontSize: 11, color: context.palette.mutedText),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final addPhoto = AppLocalizations.of(context).ownerVehicleAddPhoto;
    return GestureDetector(
      onTap: () => showComingSoonSnack(context, addPhoto),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: context.palette.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withAlpha(80),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              addPhoto,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasicInfoCard extends StatelessWidget {
  const _BasicInfoCard({
    required this.nameController,
    required this.priceController,
    required this.selectedType,
    required this.types,
    required this.onTypeChanged,
  });

  final TextEditingController nameController;
  final TextEditingController priceController;
  final String selectedType;
  final Map<String, String> types;
  final ValueChanged<String> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: l10n.ownerVehicleBasicInfo),
          const SizedBox(height: 14),
          _FormField(
            label: l10n.ownerVehicleName,
            hint: l10n.ownerVehicleNameHint,
            controller: nameController,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  label: l10n.ownerVehiclePricePerHour,
                  hint: l10n.ownerVehiclePriceHint,
                  controller: priceController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeDropdown(
                  value: selectedType,
                  items: types,
                  onChanged: onTypeChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.palette.secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: context.palette.mutedText,
            ),
            filled: true,
            fillColor: context.palette.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
          ),
          style: TextStyle(fontSize: 13, color: context.palette.darkText),
        ),
      ],
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).ownerVehicleType,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.palette.secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.palette.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
          ),
          style: TextStyle(fontSize: 13, color: context.palette.darkText),
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.latController,
    required this.lngController,
  });

  final TextEditingController latController;
  final TextEditingController lngController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: l10n.ownerVehicleLocation),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  label: l10n.ownerVehicleLat,
                  hint: l10n.ownerVehicleLatHint,
                  controller: latController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormField(
                  label: l10n.ownerVehicleLng,
                  hint: l10n.ownerVehicleLngHint,
                  controller: lngController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.ownerVehicleMapSoon,
            style: TextStyle(fontSize: 11, color: context.palette.mutedText),
          ),
        ],
      ),
    );
  }
}

class _SpecsCard extends StatelessWidget {
  const _SpecsCard({
    required this.seatsController,
    required this.doorsController,
    required this.cityController,
    required this.transmission,
    required this.transmissions,
    required this.onTransmissionChanged,
  });

  final TextEditingController seatsController;
  final TextEditingController doorsController;
  final TextEditingController cityController;
  final String? transmission;
  final Map<String, String> transmissions;
  final ValueChanged<String> onTransmissionChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: l10n.ownerVehicleSpecs),
          const SizedBox(height: 4),
          Text(
            l10n.ownerVehicleSpecsHint,
            style: TextStyle(fontSize: 11, color: context.palette.mutedText),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  label: l10n.ownerVehicleSeats,
                  hint: l10n.ownerVehicleSeatsHint,
                  controller: seatsController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormField(
                  label: l10n.ownerVehicleDoors,
                  hint: l10n.ownerVehicleDoorsHint,
                  controller: doorsController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LabeledDropdown(
            label: l10n.ownerVehicleTransmission,
            value: transmission ?? '',
            items: transmissions,
            onChanged: onTransmissionChanged,
          ),
          const SizedBox(height: 12),
          _FormField(
            label: l10n.ownerVehicleCity,
            hint: l10n.ownerVehicleCityHint,
            controller: cityController,
          ),
        ],
      ),
    );
  }
}

/// Dropdown có nhãn dùng chung (loại xe, hộp số…).
class _LabeledDropdown extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.palette.secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.palette.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
          ),
          style: TextStyle(fontSize: 13, color: context.palette.darkText),
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: AppLocalizations.of(context).ownerVehicleDescription,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(
                context,
              ).ownerVehicleDescriptionHint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: context.palette.mutedText,
              ),
              filled: true,
              fillColor: context.palette.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.palette.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.palette.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: TextStyle(fontSize: 13, color: context.palette.darkText),
          ),
        ],
      ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  const _OptionsCard({
    required this.isElectric,
    required this.deliveryAvailable,
    required this.onElectricChanged,
    required this.onDeliveryChanged,
  });

  final bool isElectric;
  final bool deliveryAvailable;
  final ValueChanged<bool> onElectricChanged;
  final ValueChanged<bool> onDeliveryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: l10n.ownerVehicleOptions),
          const SizedBox(height: 12),
          _ToggleRow(
            emoji: '⚡',
            label: l10n.ownerVehicleEv,
            subtitle: l10n.ownerVehicleEvSubtitle,
            value: isElectric,
            onChanged: onElectricChanged,
          ),
          Divider(color: context.palette.border, height: 20),
          _ToggleRow(
            emoji: '📦',
            label: l10n.bookingDelivery,
            subtitle: l10n.ownerVehicleDeliverySubtitle,
            value: deliveryAvailable,
            onChanged: onDeliveryChanged,
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String emoji;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.palette.darkText,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: context.palette.mutedText,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withAlpha(80),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
