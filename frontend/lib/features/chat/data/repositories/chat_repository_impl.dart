import 'package:frontend/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:frontend/features/chat/data/models/chat_models.dart';
import 'package:frontend/features/chat/domain/entities/conversation.dart';
import 'package:frontend/features/chat/domain/entities/message.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._remote);

  final ChatRemoteDataSource _remote;

  @override
  Future<List<Conversation>> listConversations() async =>
      ConversationModel.listFromJson(await _remote.listConversations());

  @override
  Future<Conversation> createOrGetConversation({
    String? participantId,
    String? bookingId,
  }) async => ConversationModel.fromJson(
    await _remote.createConversation(
      participantId: participantId,
      bookingId: bookingId,
    ),
  );

  @override
  Future<List<Message>> listMessages(
    String conversationId, {
    int page = 1,
    int limit = 30,
  }) async => MessageModel.listFromJson(
    await _remote.listMessages(conversationId, page: page, limit: limit),
  );

  @override
  Future<Message> sendMessage(String conversationId, String body) async =>
      MessageModel.fromJson(await _remote.sendMessage(conversationId, body));
}
