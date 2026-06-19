import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/chat/domain/usecases/list_conversations_usecase.dart';
import 'package:frontend/features/chat/presentation/cubit/conversation_list_state.dart';

export 'package:frontend/features/chat/presentation/cubit/conversation_list_state.dart';

/// Nạp danh sách hội thoại của người dùng hiện tại.
class ConversationListCubit extends Cubit<ConversationListState> {
  ConversationListCubit({required ListConversationsUseCase listConversations})
    : _listConversations = listConversations,
      super(const ConversationListLoading());

  final ListConversationsUseCase _listConversations;

  Future<void> load() async {
    emit(const ConversationListLoading());
    try {
      emit(ConversationListLoaded(await _listConversations()));
    } on ApiException catch (e) {
      emit(ConversationListError(e.message));
    }
  }
}
