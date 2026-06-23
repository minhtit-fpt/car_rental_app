import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/notification/domain/entities/notification.dart';
import 'package:frontend/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationCubit>(
      create: (_) => sl<NotificationCubit>()..load(),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.palette.background,
        appBar: AppBar(
          backgroundColor: context.palette.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final unread = state is NotificationLoaded
                  ? state.data.unreadCount
                  : 0;
              return Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      gradient: AppColors.logoGradient,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).settingsNotifications,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.palette.darkText,
                    ),
                  ),
                  if (unread > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => context.read<NotificationCubit>().markAllRead(),
              child: Text(
                AppLocalizations.of(context).notifMarkAllRead,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: context.palette.border),
          ),
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) => switch (state) {
            NotificationLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            NotificationError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<NotificationCubit>().load(),
            ),
            NotificationLoaded(:final data) =>
              data.items.isEmpty
                  ? const _EmptyView()
                  : RefreshIndicator(
                      onRefresh: () => context.read<NotificationCubit>().load(),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: data.items.length,
                        separatorBuilder: (_, _) => Divider(
                          color: context.palette.border,
                          height: 1,
                          indent: 68,
                        ),
                        itemBuilder: (context, index) => _NotifTile(
                          notif: data.items[index],
                          onTap: () => context
                              .read<NotificationCubit>()
                              .markRead(data.items[index].id),
                        ),
                      ),
                    ),
          },
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).notifEmpty,
            style: TextStyle(fontSize: 14, color: context.palette.mutedText),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.palette.secondaryText,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).commonRetry),
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif, required this.onTap});
  final AppNotification notif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final info = _typeInfo(context, notif.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notif.isRead ? null : AppColors.primary.withAlpha(7),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: info.color.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(info.emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            color: context.palette.darkText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _relativeTime(notif.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: context.palette.mutedText,
                        ),
                      ),
                    ],
                  ),
                  if (notif.body != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      notif.body!,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.palette.secondaryText,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (!notif.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
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

/// Định dạng thời gian tương đối ngắn gọn (tiếng Việt).
String _relativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays == 1) return 'Hôm qua';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  return '${time.day}/${time.month}';
}
