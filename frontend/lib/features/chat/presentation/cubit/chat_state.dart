import 'package:frontend/features/chat/domain/entities/message.dart';

sealed class ChatState {
  const ChatState();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatLoaded extends ChatState {
  const ChatLoaded(this.messages, {this.isSending = false});

  /// Tin nhắn theo thứ tự cũ → mới (để hiển thị từ trên xuống).
  final List<Message> messages;
  final bool isSending;

  ChatLoaded copyWith({List<Message>? messages, bool? isSending}) => ChatLoaded(
    messages ?? this.messages,
    isSending: isSending ?? this.isSending,
  );
}

final class ChatError extends ChatState {
  const ChatError(this.message);
  final String message;
}
