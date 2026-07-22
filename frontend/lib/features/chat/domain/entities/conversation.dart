/// Đối tác trong hội thoại (người dùng còn lại).
class ChatPartner {
  const ChatPartner({required this.id, required this.name});
  final String id;
  final String name;
}

/// Một hội thoại — phản chiếu `PublicConversation` của backend.
class Conversation {
  const Conversation({
    required this.id,
    required this.unreadCount,
    this.bookingId,
    this.partner,
    this.lastMessage,
    this.lastMessageAt,
  });

  final String id;
  final String? bookingId;
  final ChatPartner? partner;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
}
