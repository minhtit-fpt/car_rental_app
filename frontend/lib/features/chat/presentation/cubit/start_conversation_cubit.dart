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
  const StartConversationReady(this.conversationId, {this.partnerName});

  /// Id hội thoại để điều hướng tới [ChatScreen].
  final String conversationId;

  /// Tên đối tác (nếu backend trả về) — dùng làm tiêu đề màn chat.
  final String? partnerName;
}

final class StartConversationError extends StartConversationState {
  const StartConversationError(this.message);
  final String message;
}

/// Mở (tạo hoặc lấy) hội thoại với một người dùng hoặc theo booking —
/// dùng cho nút "Nhắn tin" ở màn chi tiết xe / chi tiết đơn đặt.
class StartConversationCubit extends Cubit<StartConversationState> {
  StartConversationCubit({
    required CreateOrGetConversationUseCase createOrGetConversation,
  }) : _createOrGetConversation = createOrGetConversation,
       super(const StartConversationIdle());

  final CreateOrGetConversationUseCase _createOrGetConversation;

  Future<void> open({String? participantId, String? bookingId}) async {
    assert(participantId != null || bookingId != null);
    if (state is StartConversationInProgress) return;
    emit(const StartConversationInProgress());
    try {
      final conversation = await _createOrGetConversation(
        participantId: participantId,
        bookingId: bookingId,
      );
      emit(
        StartConversationReady(
          conversation.id,
          partnerName: conversation.partner?.name,
        ),
      );
    } on ApiException catch (e) {
      emit(StartConversationError(e.message));
    }
  }
}
