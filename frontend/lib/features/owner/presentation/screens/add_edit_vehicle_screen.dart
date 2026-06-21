import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/owner/presentation/cubit/vehicle_form_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/section_header.dart';

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

  // Hộp số: value gửi server → nhãn hiển thị. Mục đầu = không áp dụng (null).
  static const _transmissions = {
    '': 'Không áp dụng',
    'AUTOMATIC': 'Tự động',
    'MANUAL': 'Số sàn',
  };

  // Khớp enum VehicleType của backend: value gửi server → nhãn hiển thị.
  static const _types = {
    'CAR': 'Ô tô',
    'MOTORBIKE': 'Xe máy',
    'BICYCLE': 'Xe đạp',
  };

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    final title = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    if (title.isEmpty) return _snack('Vui lòng nhập tên xe');
    if (price == null || price <= 0) return _snack('Giá thuê phải lớn hơn 0');

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
        return _snack('Toạ độ không hợp lệ');
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
        _snack(widget.isEdit ? 'Cập nhật xe thành công' : 'Đăng xe thành công');
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            RvSliverAppBar(
              title: widget.isEdit ? 'Chỉnh sửa xe' : 'Đăng xe mới',
              subtitle: widget.isEdit
                  ? 'Cập nhật thông tin xe của bạn'
                  : 'Điền thông tin để đăng xe',
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
                      types: _types,
                      onTypeChanged: (t) =>
                          setState(() => _selectedType = t),
                    ),
                    const SizedBox(height: 16),
                    _SpecsCard(
                      seatsController: _seatsController,
                      doorsController: _doorsController,
                      cityController: _cityController,
                      transmission: _transmission,
                      transmissions: _transmissions,
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
                      onElectricChanged: (v) =>
                          setState(() => _isElectric = v),
                      onDeliveryChanged: (v) =>
                          setState(() => _deliveryAvailable = v),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: widget.isEdit ? 'Lưu thay đổi' : 'Đăng xe',
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
          const SectionHeader(title: 'Ảnh xe'),
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
          const Text(
            'Tối đa 10 ảnh · Ảnh đầu tiên là ảnh bìa',
            style: TextStyle(fontSize: 11, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withAlpha(80),
            width: 1.5,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: AppColors.primary, size: 28),
            SizedBox(height: 4),
            Text(
              'Thêm ảnh',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500),
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
          const SectionHeader(title: 'Thông tin cơ bản'),
          const SizedBox(height: 14),
          _FormField(
            label: 'Tên xe',
            hint: 'VD: Toyota Camry 2024',
            controller: nameController,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  label: 'Giá/giờ (VNĐ)',
                  hint: 'VD: 50000',
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                fontSize: 13, color: AppColors.mutedText),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            isDense: true,
          ),
          style: const TextStyle(
              fontSize: 13, color: AppColors.darkText),
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
        const Text(
          'Loại xe',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            isDense: true,
          ),
          style: const TextStyle(
              fontSize: 13, color: AppColors.darkText),
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
          const SectionHeader(title: 'Vị trí xe'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  label: 'Vĩ độ (lat)',
                  hint: 'VD: 21.0278',
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
                  label: 'Kinh độ (lng)',
                  hint: 'VD: 105.8342',
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
          const Text(
            'Chọn vị trí trên bản đồ sẽ sớm được hỗ trợ.',
            style: TextStyle(fontSize: 11, color: AppColors.mutedText),
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
          const SectionHeader(title: 'Thông số kỹ thuật'),
          const SizedBox(height: 4),
          const Text(
            'Có thể bỏ trống nếu không áp dụng (vd: xe máy, xe đạp).',
            style: TextStyle(fontSize: 11, color: AppColors.mutedText),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  label: 'Số chỗ',
                  hint: 'VD: 5',
                  controller: seatsController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormField(
                  label: 'Số cửa',
                  hint: 'VD: 4',
                  controller: doorsController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LabeledDropdown(
            label: 'Hộp số',
            value: transmission ?? '',
            items: transmissions,
            onChanged: onTransmissionChanged,
          ),
          const SizedBox(height: 12),
          _FormField(
            label: 'Thành phố',
            hint: 'VD: TP. HCM',
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
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
          style: const TextStyle(fontSize: 13, color: AppColors.darkText),
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
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Mô tả tình trạng, tiện ích nổi bật của xe...',
              hintStyle: const TextStyle(
                  fontSize: 13, color: AppColors.mutedText),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(
                fontSize: 13, color: AppColors.darkText),
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
          const SectionHeader(title: 'Tùy chọn'),
          const SizedBox(height: 12),
          _ToggleRow(
            emoji: '⚡',
            label: 'Xe điện (EV)',
            subtitle: 'Hiển thị badge EV trên listing',
            value: isElectric,
            onChanged: onElectricChanged,
          ),
          const Divider(color: AppColors.border, height: 20),
          _ToggleRow(
            emoji: '📦',
            label: 'Giao xe tận nơi',
            subtitle: 'Cho phép giao xe đến địa chỉ khách',
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
              Text(label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  )),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.mutedText)),
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
