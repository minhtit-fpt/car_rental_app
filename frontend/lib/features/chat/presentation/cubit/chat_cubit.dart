import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
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
  static const _pageSize = 50;

  String? _conversationId;
  Timer? _pollTimer;

  /// Số trang đã tải (trang 1 = tin mới nhất, tăng dần về quá khứ).
  int _pages = 1;

  Future<void> start(String conversationId) async {
    _conversationId = conversationId;
    _pages = 1;
    await _refresh(showLoading: true);
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _refresh());
  }

  Future<void> _refresh({bool showLoading = false}) async {
    final id = _conversationId;
    if (id == null) return;
    if (showLoading) emit(const ChatLoading());
    try {
      final fresh = (await _listMessages(
        id,
        limit: _pageSize,
      )).reversed.toList(growable: false);
      if (isClosed) return;
      final current = state;
      // Đang gửi tin: bỏ qua kết quả poll để không ghi đè tin optimistic.
      if (!showLoading && current is ChatLoaded && current.isSending) return;
      if (!showLoading && current is ChatLoaded) {
        // Giữ lại tin cũ đã tải qua loadMore, ghép với trang mới nhất.
        final freshIds = fresh.map((m) => m.id).toSet();
        emit(
          current.copyWith(
            messages: [
              ...current.messages.where((m) => !freshIds.contains(m.id)),
              ...fresh,
            ],
          ),
        );
      } else {
        emit(ChatLoaded(fresh, hasMore: fresh.length >= _pageSize));
      }
    } on Exception catch (e) {
      if (isClosed) return;
      // Chỉ hiện lỗi khi đang tải lần đầu; polling lỗi thì giữ nguyên.
      if (state is! ChatLoaded) {
        emit(ChatError(e is ApiException ? e.message : e.toString()));
      }
    }
  }

  /// Tải thêm tin cũ hơn (khi cuộn lên đầu danh sách).
  Future<void> loadMore() async {
    final id = _conversationId;
    final current = state;
    if (id == null || current is! ChatLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;
    emit(current.copyWith(isLoadingMore: true));
    try {
      final older = (await _listMessages(
        id,
        page: _pages + 1,
        limit: _pageSize,
      )).reversed.toList(growable: false);
      if (isClosed) return;
      _pages++;
      final latest = state;
      if (latest is! ChatLoaded) return;
      // ponytail: tin mới đến làm lệch trang — dedupe theo id đủ tốt,
      // chuyển sang cursor-based nếu chat rất dày.
      final ids = latest.messages.map((m) => m.id).toSet();
      emit(
        latest.copyWith(
          messages: [
            ...older.where((m) => !ids.contains(m.id)),
            ...latest.messages,
          ],
          hasMore: older.length >= _pageSize,
          isLoadingMore: false,
        ),
      );
    } on Exception {
      if (isClosed) return;
      final latest = state;
      if (latest is ChatLoaded) emit(latest.copyWith(isLoadingMore: false));
    }
  }

  Future<String?> send(String body) async {
    final id = _conversationId;
    if (id == null) return 'Hội thoại không hợp lệ';
    final current = state;
    final base = current is ChatLoaded ? current : const ChatLoaded([]);
    emit(base.copyWith(isSending: true));
    try {
      final sent = await _sendMessage(id, body);
      if (isClosed) return null;
      final latest = state;
      final loaded = latest is ChatLoaded ? latest : base;
      // Dedupe theo id: nếu poll đã kịp trả về tin này thì không thêm lần 2.
      emit(
        loaded.copyWith(
          messages: [...loaded.messages.where((m) => m.id != sent.id), sent],
          isSending: false,
        ),
      );
      return null;
    } on ApiException catch (e) {
      if (isClosed) return e.message;
      final latest = state;
      if (latest is ChatLoaded) emit(latest.copyWith(isSending: false));
      return e.message;
    }
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
