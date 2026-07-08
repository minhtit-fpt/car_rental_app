/// Vai trò một lượt hội thoại với trợ lý AI.
enum ChatRole { user, assistant }

/// Xe được nhắc trong câu trả lời của trợ lý — dùng để render tên xe thành link
/// bấm mở màn chi tiết (`/vehicles/:id`).
class VehicleRef {
  const VehicleRef({required this.id, required this.name});

  final String id;
  final String name;
}

/// Một tin nhắn trong phiên chat với trợ lý AI.
///
/// Bất biến: cập nhật nội dung khi streaming bằng [copyWith], không sửa tại chỗ.
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    this.isStreaming = false,
    this.vehicles = const [],
  });

  final ChatRole role;
  final String content;

  /// True khi assistant đang nhận dần delta (hiện con trỏ nhấp nháy/typing).
  final bool isStreaming;

  /// Xe được nhắc trong câu trả lời (chỉ với tin assistant) — để linkify tên xe.
  final List<VehicleRef> vehicles;

  bool get isUser => role == ChatRole.user;

  ChatMessage copyWith({
    String? content,
    bool? isStreaming,
    List<VehicleRef>? vehicles,
  }) => ChatMessage(
    role: role,
    content: content ?? this.content,
    isStreaming: isStreaming ?? this.isStreaming,
    vehicles: vehicles ?? this.vehicles,
  );

  /// Định dạng 1 lượt cho lịch sử gửi lên API ({role, content}).
  Map<String, String> toHistoryJson() => {
    'role': role == ChatRole.user ? 'user' : 'assistant',
    'content': content,
  };
}
