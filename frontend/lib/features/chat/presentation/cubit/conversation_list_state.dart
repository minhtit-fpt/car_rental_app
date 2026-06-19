import 'package:frontend/features/chat/domain/entities/conversation.dart';

sealed class ConversationListState {
  const ConversationListState();
}

final class ConversationListLoading extends ConversationListState {
  const ConversationListLoading();
}

final class ConversationListLoaded extends ConversationListState {
  const ConversationListLoaded(this.conversations);
  final List<Conversation> conversations;
}

final class ConversationListError extends ConversationListState {
  const ConversationListError(this.message);
  final String message;
}
