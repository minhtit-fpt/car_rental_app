import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/notification/domain/entities/notification.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

/// Màn chi tiết một thông báo — mở khi người dùng bấm vào một dòng noti.
class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key, required this.notif});

  final AppNotification notif;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = _typeInfo(context, notif.type);
    final bookingId = notif.payload?['bookingId'];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.palette.background,
        appBar: AppBar(
          backgroundColor: context.palette.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            l10n.notifDetailTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.palette.darkText,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: context.palette.border),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.palette.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.palette.border),
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
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: info.color.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              info.emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.palette.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatDateTime(notif.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.palette.mutedText,
                      ),
                    ),
                    if (notif.body != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        notif.body!,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: context.palette.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (bookingId != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(notif.targetRoute ?? '/trips'),
                    icon: const Icon(Icons.directions_car_outlined, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: Text(l10n.notifViewTrip),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  ({String emoji, Color color}) _typeInfo(
    BuildContext context,
    NotificationType type,
  ) {
    return switch (type) {
      NotificationType.booking => (emoji: '🚗', color: AppColors.primary),
      NotificationType.payment => (emoji: '💳', color: AppColors.success),
      NotificationType.kyc => (emoji: '🛡️', color: AppColors.teal),
      NotificationType.chat => (emoji: '💬', color: AppColors.primary),
      NotificationType.promotion => (emoji: '🎁', color: AppColors.orange),
      NotificationType.system => (emoji: '🔔', color: context.palette.mutedText),
    };
  }
}

/// Định dạng ngày giờ đầy đủ (vd "08:00 · 25/06/2026").
String _formatDateTime(DateTime time) {
  final local = time.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.hour)}:${two(local.minute)} · '
      '${two(local.day)}/${two(local.month)}/${local.year}';
}
