import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

/// Số khẩn cấp quốc gia Việt Nam (sự thật, không bịa). Chỉ hiển thị + copy —
/// không tự quay số (tính năng Gọi đã được descope theo plan).
class _Hotline {
  const _Hotline({required this.label, required this.number, required this.icon});
  final String label;
  final String number;
  final IconData icon;
}

/// Bottom sheet Khẩn cấp: hotline quốc gia + mẹo an toàn. Chạm số để sao chép.
Future<void> showEmergencySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _EmergencySheet(),
  );
}

class _EmergencySheet extends StatelessWidget {
  const _EmergencySheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hotlines = <_Hotline>[
      _Hotline(
        label: l10n.emergencyPolice,
        number: '113',
        icon: Icons.local_police_outlined,
      ),
      _Hotline(
        label: l10n.emergencyFire,
        number: '114',
        icon: Icons.local_fire_department_outlined,
      ),
      _Hotline(
        label: l10n.emergencyAmbulance,
        number: '115',
        icon: Icons.medical_services_outlined,
      ),
    ];
    final tips = <String>[
      l10n.emergencyTipSafePlace,
      l10n.emergencyTipShareLocation,
      l10n.emergencyTipNoteDetails,
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emergency_rounded, color: AppColors.danger),
                const SizedBox(width: 8),
                Text(
                  l10n.emergencySheetTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.emergencySheetSubtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            for (final h in hotlines) ...[
              _HotlineRow(hotline: h),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            Text(
              l10n.emergencyTipsTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            for (final tip in tips) ...[
              _TipRow(text: tip),
              const SizedBox(height: 6),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _HotlineRow extends StatelessWidget {
  const _HotlineRow({required this.hotline});

  final _Hotline hotline;

  Future<void> _copy(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: hotline.number));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.emergencyNumberCopied(hotline.label, hotline.number),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _copy(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(hotline.icon, size: 20, color: AppColors.danger),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hotline.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ),
            Text(
              hotline.number,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.copy_rounded,
              size: 16,
              color: AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }
}
