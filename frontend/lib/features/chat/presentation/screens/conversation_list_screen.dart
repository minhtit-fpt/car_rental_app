import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';

class _Conversation {
  const _Conversation({
    required this.id,
    required this.name,
    required this.emoji,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    this.vehicleName = '',
  });
  final String id;
  final String name;
  final String emoji;
  final String lastMessage;
  final String time;
  final int unread;
  final String vehicleName;
}

const _kConversations = [
  _Conversation(
    id: '1',
    name: 'Minh T.',
    emoji: '👤',
    lastMessage: 'Xe đã sẵn sàng, bạn nhận lúc mấy giờ?',
    time: '14:32',
    unread: 2,
    vehicleName: 'Tesla Model 3',
  ),
  _Conversation(
    id: '2',
    name: 'Linh N.',
    emoji: '👤',
    lastMessage: 'Cảm ơn bạn đã thuê xe của mình!',
    time: 'Hôm qua',
    vehicleName: 'BMW X5',
  ),
  _Conversation(
    id: '3',
    name: 'Đức P.',
    emoji: '👤',
    lastMessage: 'Bạn có thể gia hạn thêm 1 ngày không?',
    time: '10/05',
    unread: 1,
    vehicleName: 'Mercedes C300',
  ),
  _Conversation(
    id: '4',
    name: 'Hoa L.',
    emoji: '👤',
    lastMessage: 'Mình đã nhận được xe rồi, cảm ơn!',
    time: '08/05',
    vehicleName: 'Toyota Camry',
  ),
];

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
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
              const Text(
                'Tin nhắn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border),
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _kConversations.length,
          separatorBuilder: (_, _) =>
              const Divider(color: AppColors.border, height: 1, indent: 70),
          itemBuilder: (context, index) {
            final conv = _kConversations[index];
            return _ConversationTile(
              conversation: conv,
              onTap: () => context.push('/chat/${conv.id}', extra: conv.name),
            );
          },
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  final _Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unread > 0;

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
                  child: Center(
                    child: Text(
                      conversation.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
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
                          '${conversation.unread}',
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
                        conversation.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: hasUnread
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        conversation.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread
                              ? AppColors.primary
                              : AppColors.mutedText,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (conversation.vehicleName.isNotEmpty)
                    Text(
                      '🚗 ${conversation.vehicleName}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    conversation.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasUnread
                          ? AppColors.darkText
                          : AppColors.mutedText,
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
