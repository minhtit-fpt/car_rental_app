import 'package:frontend/features/chat/domain/entities/conversation.dart';
import 'package:frontend/features/chat/domain/entities/message.dart';

/// Hợp đồng domain cho chat (`/api/conversations`).
abstract interface class ChatRepository {
  /// `GET /api/conversations` — danh sách hội thoại.
  Future<List<Conversation>> listConversations();

  /// `POST /api/conversations` — tạo/lấy hội thoại.
  Future<Conversation> createOrGetConversation({
    String? participantId,
    String? bookingId,
  });

  /// `GET /api/conversations/:id/messages` — tin nhắn (mới trước).
  Future<List<Message>> listMessages(
    String conversationId, {
    int page,
    int limit,
  });

  /// `POST /api/conversations/:id/messages` — gửi tin nhắn.
  Future<Message> sendMessage(String conversationId, String body);
}
