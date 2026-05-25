import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';
import 'package:frontend/shared/widgets/section_header.dart';

class AddEditVehicleScreen extends StatefulWidget {
  const AddEditVehicleScreen({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _nameController = TextEditingController(text: '');
  final _priceController = TextEditingController(text: '');
  final _descController = TextEditingController(text: '');
  String _selectedType = 'Sedan';
  bool _isElectric = false;
  bool _deliveryAvailable = false;
  bool _isSubmitting = false;

  static const _types = ['Sedan', 'SUV', 'Pickup', 'Hatchback', 'Van'];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _nameController.text = 'Tesla Model 3';
      _priceController.text = '890';
      _descController.text = 'Xe điện cao cấp, trang bị đầy đủ tiện nghi.';
      _selectedType = 'Sedan';
      _isElectric = true;
      _deliveryAvailable = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) context.pop();
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
                    _DescriptionCard(controller: _descController),
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
  final List<String> types;
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
                  label: 'Giá/ngày (K VNĐ)',
                  hint: 'VD: 850',
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
  final List<String> items;
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
          items: items
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
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
