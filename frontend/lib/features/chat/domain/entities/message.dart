/// Một tin nhắn — phản chiếu `PublicMessage` của backend.
class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.sentAt,
    this.readAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final DateTime sentAt;
  final DateTime? readAt;
}
