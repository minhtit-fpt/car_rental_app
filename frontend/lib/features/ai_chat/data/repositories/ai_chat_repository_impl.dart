import 'package:frontend/features/ai_chat/data/datasources/ai_chat_remote_datasource.dart';
import 'package:frontend/features/ai_chat/domain/entities/chat_message.dart';
import 'package:frontend/features/ai_chat/domain/repositories/ai_chat_repository.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  const AiChatRepositoryImpl(this._remote);

  final AiChatRemoteDataSource _remote;

  @override
  Stream<String> streamReply({
    required String message,
    required List<ChatMessage> history,
  }) {
    return _remote.streamReply(
      message: message,
      history: history.map((m) => m.toHistoryJson()).toList(),
    );
  }
}
