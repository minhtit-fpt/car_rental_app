import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/chat/domain/entities/message.dart';
import 'package:frontend/features/chat/domain/usecases/list_messages_usecase.dart';
import 'package:frontend/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:frontend/features/chat/presentation/cubit/chat_state.dart';

export 'package:frontend/features/chat/presentation/cubit/chat_state.dart';

/// Quản lý tin nhắn của một hội thoại + polling định kỳ (REST + polling).
class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required ListMessagesUseCase listMessages,
    required SendMessageUseCase sendMessage,
  }) : _listMessages = listMessages,
       _sendMessage = sendMessage,
       super(const ChatLoading());

  final ListMessagesUseCase _listMessages;
  final SendMessageUseCase _sendMessage;

  static const _pollInterval = Duration(seconds: 4);

  String? _conversationId;
  Timer? _pollTimer;

  Future<void> start(String conversationId) async {
    _conversationId = conversationId;
    await _refresh(showLoading: true);
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _refresh());
  }

  Future<void> _refresh({bool showLoading = false}) async {
    final id = _conversationId;
    if (id == null) return;
    if (showLoading) emit(const ChatLoading());
    try {
      final messages = await _listMessages(id, limit: 50);
      final ordered = messages.reversed.toList(growable: false);
      final current = state;
      emit(
        ChatLoaded(
          ordered,
          isSending: current is ChatLoaded ? current.isSending : false,
        ),
      );
    } on ApiException catch (e) {
      // Chỉ hiện lỗi khi đang tải lần đầu; polling lỗi thì giữ nguyên.
      if (state is! ChatLoaded) emit(ChatError(e.message));
    }
  }

  Future<String?> send(String body) async {
    final id = _conversationId;
    if (id == null) return 'Hội thoại không hợp lệ';
    final current = state;
    final base = current is ChatLoaded ? current.messages : <Message>[];
    emit(ChatLoaded(base, isSending: true));
    try {
      final sent = await _sendMessage(id, body);
      emit(ChatLoaded([...base, sent], isSending: false));
      return null;
    } on ApiException catch (e) {
      emit(ChatLoaded(base, isSending: false));
      return e.message;
    }
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
