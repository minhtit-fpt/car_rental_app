import 'package:frontend/features/ai_chat/domain/entities/chat_message.dart';

/// State của phiên chat với trợ lý AI. Bất biến — luôn tạo bản sao qua [copyWith].
class AiChatState {
  const AiChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.error,
  });

  final List<ChatMessage> messages;

  /// Đang nhận stream câu trả lời (khoá ô nhập để tránh gửi chồng).
  final bool isStreaming;

  /// Lỗi gần nhất (mạng/service) — hiển thị banner, không chèn vào hội thoại.
  final String? error;

  bool get isEmpty => messages.isEmpty;

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    String? error,
    bool clearError = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
