import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/chat/domain/entities/conversation.dart';
import 'package:frontend/features/chat/presentation/cubit/conversation_list_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConversationListCubit>(
      create: (_) => sl<ConversationListCubit>()..load(),
      child: const _ConversationListView(),
    );
  }
}

class _ConversationListView extends StatelessWidget {
  const _ConversationListView();

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
          title: Row(
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
                AppLocalizations.of(context).chatTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.palette.darkText,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: context.palette.border),
          ),
        ),
        body: BlocBuilder<ConversationListCubit, ConversationListState>(
          builder: (context, state) => switch (state) {
            ConversationListLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ConversationListError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<ConversationListCubit>().load(),
            ),
            ConversationListLoaded(:final conversations) =>
              conversations.isEmpty
                  ? const _EmptyView()
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<ConversationListCubit>().load(),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: conversations.length,
                        separatorBuilder: (_, _) => Divider(
                          color: context.palette.border,
                          height: 1,
                          indent: 70,
                        ),
                        itemBuilder: (context, index) {
                          final conv = conversations[index];
                          return _ConversationTile(
                            conversation: conv,
                            onTap: () async {
                              await context.push(
                                '/chat/${conv.id}',
                                extra:
                                    conv.partner?.name ??
                                    AppLocalizations.of(
                                      context,
                                    ).chatPartnerFallback,
                              );
                              if (context.mounted) {
                                await context
                                    .read<ConversationListCubit>()
                                    .load();
                              }
                            },
                          );
                        },
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
          const Text('💬', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).chatEmpty,
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

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('👤', style: TextStyle(fontSize: 22)),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${conversation.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conversation.partner?.name ??
                            AppLocalizations.of(context).chatPartnerFallback,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: hasUnread
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: context.palette.darkText,
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _shortTime(
                            AppLocalizations.of(context),
                            conversation.lastMessageAt!,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? AppColors.primary
                                : context.palette.mutedText,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conversation.lastMessage ??
                        AppLocalizations.of(context).chatStartConversation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasUnread
                          ? context.palette.darkText
                          : context.palette.mutedText,
                      fontWeight: hasUnread
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _shortTime(AppLocalizations l10n, DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inDays == 0) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
  if (diff.inDays == 1) return l10n.chatYesterday;
  return '${time.day}/${time.month}';
}
