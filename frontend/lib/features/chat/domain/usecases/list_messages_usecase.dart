import 'package:frontend/features/chat/domain/entities/message.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';

/// Lấy tin nhắn trong hội thoại (`GET /api/conversations/:id/messages`).
class ListMessagesUseCase {
  const ListMessagesUseCase(this._repository);

  final ChatRepository _repository;

  Future<List<Message>> call(
    String conversationId, {
    int page = 1,
    int limit = 30,
  }) => _repository.listMessages(conversationId, page: page, limit: limit);
}
