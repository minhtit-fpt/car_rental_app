import 'package:frontend/features/ai_chat/domain/entities/chat_message.dart';
import 'package:frontend/features/ai_chat/domain/repositories/ai_chat_repository.dart';

/// Stream câu trả lời của trợ lý AI cho một câu hỏi (kèm lịch sử hội thoại).
class StreamAiReplyUseCase {
  const StreamAiReplyUseCase(this._repository);

  final AiChatRepository _repository;

  Stream<String> call({
    required String message,
    required List<ChatMessage> history,
  }) => _repository.streamReply(message: message, history: history);
}
