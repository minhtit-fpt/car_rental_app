import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

/// Bottom sheet "Báo cáo sự cố" dùng chung cho quick action Báo hỏng / Chụp ảnh
/// trong chuyến đi. Cho phép đính kèm 1 ảnh (image_picker) rồi chuyển sang kênh
/// hỗ trợ in-app (`/conversations`). Không gọi backend mới.
Future<void> showReportSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _ReportSheet(),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet();

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final ImagePicker _picker = ImagePicker();
  XFile? _photo;

  Future<void> _pick(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 85);
    if (image == null || !mounted) return;
    setState(() => _photo = image);
  }

  void _continueToSupport() {
    Navigator.of(context).pop();
    context.push('/conversations');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reportSheetTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.palette.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.reportSheetSubtitle,
              style: TextStyle(
                fontSize: 13,
                color: context.palette.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            if (_photo == null)
              Row(
                children: [
                  Expanded(
                    child: _AttachButton(
                      icon: Icons.photo_camera_outlined,
                      label: l10n.reportCamera,
                      onTap: () => _pick(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AttachButton(
                      icon: Icons.photo_library_outlined,
                      label: l10n.reportGallery,
                      onTap: () => _pick(ImageSource.gallery),
                    ),
                  ),
                ],
              )
            else
              _PhotoPreview(
                photo: _photo!,
                removeLabel: l10n.reportRemovePhoto,
                attachedLabel: l10n.reportPhotoAttached,
                onRemove: () => setState(() => _photo = null),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _continueToSupport,
                icon: const Icon(Icons.headset_mic_outlined, size: 18),
                label: Text(l10n.reportContinueToSupport),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachButton extends StatelessWidget {
  const _AttachButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.palette.surfaceSunken,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.palette.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.palette.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({
    required this.photo,
    required this.attachedLabel,
    required this.removeLabel,
    required this.onRemove,
  });

  final XFile photo;
  final String attachedLabel;
  final String removeLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.palette.surfaceSunken,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(photo.path),
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              attachedLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.palette.darkText,
              ),
            ),
          ),
          TextButton(
            onPressed: onRemove,
            child: Text(
              removeLabel,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
