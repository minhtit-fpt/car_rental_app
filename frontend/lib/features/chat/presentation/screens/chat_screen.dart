import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/chat/domain/entities/message.dart';
import 'package:frontend/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.partnerName,
  });

  final String conversationId;
  final String partnerName;

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthCubit>().state.user?.id ?? '';
    return BlocProvider<ChatCubit>(
      create: (_) => sl<ChatCubit>()..start(conversationId),
      child: _ChatView(partnerName: partnerName, currentUserId: currentUserId),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({required this.partnerName, required this.currentUserId});

  final String partnerName;
  final String currentUserId;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  /// Cuộn gần lên đầu danh sách thì tải thêm tin cũ hơn.
  static const _loadMoreThreshold = 40.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= _loadMoreThreshold) {
      context.read<ChatCubit>().loadMore();
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final error = await context.read<ChatCubit>().send(text);
    if (error != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: context.palette.darkText,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.partnerName,
                style: TextStyle(
                  fontSize: 15,
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
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                // Chỉ auto-cuộn xuống khi có tin MỚI NHẤT thay đổi —
                // tải thêm tin cũ (prepend) thì giữ nguyên vị trí.
                listenWhen: (a, b) =>
                    a is ChatLoaded &&
                    b is ChatLoaded &&
                    b.messages.isNotEmpty &&
                    (a.messages.isEmpty ||
                        a.messages.last.id != b.messages.last.id),
                listener: (_, _) => _scrollToBottom(),
                builder: (context, state) => switch (state) {
                  ChatLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  ChatError(:final message) => Center(
                    child: Padding(
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
                  ),
                  ChatLoaded(:final messages, :final isLoadingMore) =>
                    messages.isEmpty
                        ? Center(
                            child: Text(
                              AppLocalizations.of(context).chatNoMessages,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.palette.mutedText,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            // +1 dòng spinner ở đầu khi đang tải tin cũ hơn.
                            itemCount: messages.length + (isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (isLoadingMore && index == 0) {
                                return const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final message =
                                  messages[index - (isLoadingMore ? 1 : 0)];
                              return _MessageBubble(
                                message: message,
                                isMe: message.senderId == widget.currentUserId,
                              );
                            },
                          ),
                },
              ),
            ),
            _InputBar(controller: _controller, onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});
  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final time =
        '${message.sentAt.hour.toString().padLeft(2, '0')}:'
        '${message.sentAt.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👤', style: TextStyle(fontSize: 13)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : context.palette.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMe
                            ? AppColors.primary.withAlpha(40)
                            : context.palette.cardShadowColor,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : context.palette.darkText,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: context.palette.mutedText,
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

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.palette.surface,
        border: Border(top: BorderSide(color: context.palette.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.palette.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.palette.border),
              ),
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).chatInputHint,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: context.palette.mutedText,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
                style: TextStyle(fontSize: 14, color: context.palette.darkText),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
