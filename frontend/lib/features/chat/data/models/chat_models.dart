import 'package:frontend/features/chat/domain/entities/conversation.dart';
import 'package:frontend/features/chat/domain/entities/message.dart';

/// Ánh xạ JSON chat của backend → entity.
abstract final class ConversationModel {
  static Conversation fromJson(Map<String, dynamic> json) {
    final partner = json['partner'] as Map<String, dynamic>?;
    return Conversation(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String?,
      partner: partner == null
          ? null
          : ChatPartner(
              id: partner['id'] as String,
              name: partner['name'] as String,
            ),
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      unreadCount: json['unreadCount'] as int,
    );
  }

  static List<Conversation> listFromJson(List<dynamic> json) => json
      .map((e) => fromJson(e as Map<String, dynamic>))
      .toList(growable: false);
}

abstract final class MessageModel {
  static Message fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    conversationId: json['conversationId'] as String,
    senderId: json['senderId'] as String,
    body: json['body'] as String,
    sentAt: DateTime.parse(json['sentAt'] as String),
    readAt: json['readAt'] == null
        ? null
        : DateTime.parse(json['readAt'] as String),
  );

  static List<Message> listFromJson(Map<String, dynamic> json) =>
      (json['items'] as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
}
