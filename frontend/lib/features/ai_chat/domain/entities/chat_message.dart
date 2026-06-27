/// Vai trò một lượt hội thoại với trợ lý AI.
enum ChatRole { user, assistant }

/// Một tin nhắn trong phiên chat với trợ lý AI.
///
/// Bất biến: cập nhật nội dung khi streaming bằng [copyWith], không sửa tại chỗ.
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    this.isStreaming = false,
  });

  final ChatRole role;
  final String content;

  /// True khi assistant đang nhận dần delta (hiện con trỏ nhấp nháy/typing).
  final bool isStreaming;

  bool get isUser => role == ChatRole.user;

  ChatMessage copyWith({String? content, bool? isStreaming}) => ChatMessage(
    role: role,
    content: content ?? this.content,
    isStreaming: isStreaming ?? this.isStreaming,
  );

  /// Định dạng 1 lượt cho lịch sử gửi lên API ({role, content}).
  Map<String, String> toHistoryJson() => {
    'role': role == ChatRole.user ? 'user' : 'assistant',
    'content': content,
  };
}
