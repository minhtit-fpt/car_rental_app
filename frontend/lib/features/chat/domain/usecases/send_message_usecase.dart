import 'package:frontend/features/chat/domain/entities/message.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';

/// Gửi tin nhắn (`POST /api/conversations/:id/messages`).
class SendMessageUseCase {
  const SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<Message> call(String conversationId, String body) =>
      _repository.sendMessage(conversationId, body);
}
