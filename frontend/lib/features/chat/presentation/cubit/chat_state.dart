import 'package:frontend/features/chat/domain/entities/message.dart';

sealed class ChatState {
  const ChatState();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatLoaded extends ChatState {
  const ChatLoaded(
    this.messages, {
    this.isSending = false,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  /// Tin nhắn theo thứ tự cũ → mới (để hiển thị từ trên xuống).
  final List<Message> messages;
  final bool isSending;

  /// Còn tin cũ hơn trên server để tải thêm (kéo lên đầu danh sách).
  final bool hasMore;
  final bool isLoadingMore;

  ChatLoaded copyWith({
    List<Message>? messages,
    bool? isSending,
    bool? hasMore,
    bool? isLoadingMore,
  }) => ChatLoaded(
    messages ?? this.messages,
    isSending: isSending ?? this.isSending,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

final class ChatError extends ChatState {
  const ChatError(this.message);
  final String message;
}
