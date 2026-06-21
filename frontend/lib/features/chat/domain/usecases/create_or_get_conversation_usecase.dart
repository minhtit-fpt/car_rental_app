import 'package:frontend/features/chat/domain/entities/conversation.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';

/// Tạo hoặc lấy hội thoại với một người dùng / theo booking
/// (`POST /api/conversations`).
class CreateOrGetConversationUseCase {
  const CreateOrGetConversationUseCase(this._repository);

  final ChatRepository _repository;

  Future<Conversation> call({String? participantId, String? bookingId}) =>
      _repository.createOrGetConversation(
        participantId: participantId,
        bookingId: bookingId,
      );
}
