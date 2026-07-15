import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/features/ai_chat/domain/entities/chat_message.dart';
import 'package:frontend/features/ai_chat/presentation/cubit/ai_chat_cubit.dart';
import 'package:frontend/features/ai_chat/presentation/cubit/ai_chat_state.dart';

/// Màn trợ lý AI (RAG chatbot) — hỏi đáp về thuê xe, giá, chuyến của tôi.
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mở lại màn: xoá hội thoại nếu phiên cũ đã quá 10 phút, ngược lại giữ nguyên.
    context.read<AiChatCubit>().resumeOrReset();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    context.read<AiChatCubit>().send(text);
    _inputController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: Column(
          children: [
            const _ChatHeader(),
            Expanded(
              child: BlocConsumer<AiChatCubit, AiChatState>(
                listenWhen: (a, b) =>
                    a.messages.length != b.messages.length ||
                    (a.messages.isNotEmpty &&
                        b.messages.isNotEmpty &&
                        a.messages.last.content != b.messages.last.content),
                listener: (_, _) => _scrollToBottom(),
                builder: (context, state) {
                  if (state.isEmpty) {
                    return _EmptyState(onSuggestionTap: _send);
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: state.messages.length,
                    itemBuilder: (_, i) => _MessageBubble(state.messages[i]),
                  );
                },
              ),
            ),
            _ErrorBanner(),
            _InputBar(controller: _inputController, onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.renterHeaderGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 14),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trợ lý RideVN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Hỏi về thuê xe, giá, chuyến của bạn',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Đoạn chat mới',
                icon: const Icon(Icons.edit_square, color: Colors.white),
                onPressed: () => _confirmNewChat(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmNewChat(BuildContext context) async {
    final cubit = context.read<AiChatCubit>();
    if (cubit.state.isEmpty) return; // chưa có gì để xoá
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bắt đầu đoạn chat mới?'),
        content: const Text('Nội dung hội thoại hiện tại sẽ bị xoá.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đoạn chat mới'),
          ),
        ],
      ),
    );
    if (ok ?? false) cubit.startNewChat();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSuggestionTap});

  final ValueChanged<String> onSuggestionTap;

  static const _suggestions = [
    'Thuê xe tự lái cần giấy tờ gì?',
    'Phạt nguội khi thuê xe ai chịu?',
    'Xe điện trả pin bao nhiêu là đủ?',
    'Chính sách huỷ chuyến thế nào?',
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.renterHeaderGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Xin chào! Mình là trợ lý RideVN',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: palette.darkText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hỏi mình về thủ tục, bảo hiểm, giá thuê hay chuyến đi của bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: palette.secondaryText),
        ),
        const SizedBox(height: 24),
        ..._suggestions.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => onSuggestionTap(s),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s,
                        style: TextStyle(fontSize: 14, color: palette.darkText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble(this.message);

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isUser = message.isUser;
    final showTyping = message.isStreaming && message.content.isEmpty;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : palette.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: palette.border),
        ),
        child: showTyping
            ? const _TypingDots()
            : _buildContent(context, palette, isUser),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppPalette palette, bool isUser) {
    final baseStyle = TextStyle(
      fontSize: 14,
      height: 1.4,
      color: isUser ? Colors.white : palette.darkText,
    );
    // Chỉ linkify tin assistant khi đã xong stream + có xe được nhắc.
    if (isUser || message.isStreaming || message.vehicles.isEmpty) {
      return Text(message.content, style: baseStyle);
    }
    return Text.rich(
      TextSpan(
        children: _linkifyVehicles(
          context,
          message.content,
          message.vehicles,
          baseStyle,
        ),
      ),
    );
  }
}

final _wordChar = RegExp(r'[\p{L}\p{N}]', unicode: true);

/// Tìm [needle] trong [text] từ [from], nhưng chỉ nhận khi 2 đầu là ranh giới từ
/// (đầu/cuối chuỗi hoặc ký tự không phải chữ/số) → tránh gạch chân nhầm khi tên
/// xe là chuỗi con của một từ khác.
int _indexOfWholeWord(String text, String needle, int from) {
  var idx = text.indexOf(needle, from);
  while (idx != -1) {
    final beforeOk = idx == 0 || !_wordChar.hasMatch(text[idx - 1]);
    final after = idx + needle.length;
    final afterOk = after >= text.length || !_wordChar.hasMatch(text[after]);
    if (beforeOk && afterOk) return idx;
    idx = text.indexOf(needle, idx + 1);
  }
  return -1;
}

/// Chia câu trả lời thành các span; tên xe khớp [vehicles] trở thành link bấm
/// mở `/vehicles/:id`. Ưu tiên tên dài trùng vị trí để không cắt nhầm.
List<InlineSpan> _linkifyVehicles(
  BuildContext context,
  String text,
  List<VehicleRef> vehicles,
  TextStyle baseStyle,
) {
  final linkStyle = baseStyle.copyWith(
    color: AppColors.accent,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.accent,
  );
  final spans = <InlineSpan>[];
  var i = 0;
  while (i < text.length) {
    VehicleRef? match;
    var matchAt = text.length;
    for (final v in vehicles) {
      if (v.name.isEmpty) continue;
      final idx = _indexOfWholeWord(text, v.name, i);
      if (idx == -1) continue;
      // Vị trí sớm hơn thắng; cùng vị trí thì tên dài hơn thắng.
      if (idx < matchAt ||
          (idx == matchAt && v.name.length > (match?.name.length ?? 0))) {
        match = v;
        matchAt = idx;
      }
    }
    if (match == null) {
      spans.add(TextSpan(text: text.substring(i), style: baseStyle));
      break;
    }
    if (matchAt > i) {
      spans.add(TextSpan(text: text.substring(i, matchAt), style: baseStyle));
    }
    final ref = match;
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: GestureDetector(
          onTap: () => context.push('/vehicles/${ref.id}'),
          child: Text(ref.name, style: linkStyle),
        ),
      ),
    );
    i = matchAt + ref.name.length;
  }
  return spans;
}

class _TypingDots extends StatelessWidget {
  const _TypingDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          3,
          (_) => Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: context.palette.mutedText,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiChatCubit, AiChatState>(
      buildWhen: (a, b) => a.error != b.error,
      builder: (context, state) {
        final error = state.error;
        if (error == null) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: AppColors.danger.withAlpha(26),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.error_outline, size: 18, color: AppColors.danger),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(fontSize: 13, color: AppColors.danger),
                ),
              ),
              GestureDetector(
                onTap: () => context.read<AiChatCubit>().clearError(),
                child: Icon(Icons.close, size: 18, color: AppColors.danger),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(top: BorderSide(color: palette.border)),
        ),
        child: BlocBuilder<AiChatCubit, AiChatState>(
          buildWhen: (a, b) => a.isStreaming != b.isStreaming,
          builder: (context, state) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: state.isStreaming ? null : onSend,
                    decoration: InputDecoration(
                      hintText: 'Nhập câu hỏi…',
                      hintStyle: TextStyle(color: palette.placeholderText),
                      filled: true,
                      fillColor: palette.surfaceSunken,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SendButton(
                  isStreaming: state.isStreaming,
                  onTap: () => onSend(controller.text),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.isStreaming, required this.onTap});

  final bool isStreaming;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isStreaming ? null : onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isStreaming ? context.palette.mutedText : AppColors.accent,
          shape: BoxShape.circle,
        ),
        child: isStreaming
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Icon(Icons.arrow_upward_rounded, color: Colors.white),
      ),
    );
  }
}
