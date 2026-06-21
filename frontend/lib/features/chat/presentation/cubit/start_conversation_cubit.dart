import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/chat/domain/usecases/create_or_get_conversation_usecase.dart';

sealed class StartConversationState {
  const StartConversationState();
}

final class StartConversationIdle extends StartConversationState {
  const StartConversationIdle();
}

final class StartConversationInProgress extends StartConversationState {
  const StartConversationInProgress();
}

final class StartConversationReady extends StartConversationState {
  const StartConversationReady(this.conversationId);

  /// Id hội thoại để điều hướng tới [ChatScreen].
  final String conversationId;
}

final class StartConversationError extends StartConversationState {
  const StartConversationError(this.message);
  final String message;
}

/// Mở (tạo hoặc lấy) hội thoại với một người dùng — dùng cho nút "Nhắn tin"
/// ở màn chi tiết xe.
class StartConversationCubit extends Cubit<StartConversationState> {
  StartConversationCubit({
    required CreateOrGetConversationUseCase createOrGetConversation,
  }) : _createOrGetConversation = createOrGetConversation,
       super(const StartConversationIdle());

  final CreateOrGetConversationUseCase _createOrGetConversation;

  Future<void> open({required String participantId}) async {
    if (state is StartConversationInProgress) return;
    emit(const StartConversationInProgress());
    try {
      final conversation = await _createOrGetConversation(
        participantId: participantId,
      );
      emit(StartConversationReady(conversation.id));
    } on ApiException catch (e) {
      emit(StartConversationError(e.message));
    }
  }
}
