import 'package:frontend/features/chat/domain/entities/conversation.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';

/// Lấy danh sách hội thoại (`GET /api/conversations`).
class ListConversationsUseCase {
  const ListConversationsUseCase(this._repository);

  final ChatRepository _repository;

  Future<List<Conversation>> call() => _repository.listConversations();
}
