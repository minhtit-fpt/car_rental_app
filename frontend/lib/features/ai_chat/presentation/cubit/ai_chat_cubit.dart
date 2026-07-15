import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/ai_chat/domain/entities/chat_message.dart';
import 'package:frontend/features/ai_chat/domain/usecases/stream_ai_reply_usecase.dart';
import 'package:frontend/features/ai_chat/presentation/cubit/ai_chat_state.dart';

/// Điều phối hội thoại với trợ lý AI: thêm tin người dùng, mở stream câu trả lời
/// và nối dần delta vào tin assistant cuối cùng.
class AiChatCubit extends Cubit<AiChatState> {
  AiChatCubit({required StreamAiReplyUseCase streamReply})
    : _streamReply = streamReply,
      super(const AiChatState());

  final StreamAiReplyUseCase _streamReply;
  StreamSubscription<String>? _sub;

  /// Cubit là singleton (sống qua điều hướng) nên hội thoại được giữ khi thoát
  /// màn chat. Quá [_retentionWindow] kể từ lượt cuối → coi như phiên cũ, tự xoá
  /// khi mở lại. ponytail: chỉ giữ trong RAM, không bền qua khi tắt app.
  static const _retentionWindow = Duration(minutes: 10);

  /// Số tin gần nhất gửi kèm làm ngữ cảnh cho LLM (~5 lượt hỏi-đáp). Cắt bớt để
  /// không vượt cửa sổ ngữ cảnh của model local (đang để 8192 token).
  static const _maxHistoryMessages = 10;

  /// Ký tự record-separator ngăn câu trả lời với metadata xe (khớp
  /// `VEHICLE_REFS_SENTINEL` cua ai-service): cau tra loi + sentinel + JSON metadata xe.
  static const _refsSentinel = '\u001E';

  DateTime? _lastActivityAt;

  /// Gọi khi mở lại màn chat: xoá hội thoại nếu đã quá [_retentionWindow].
  void resumeOrReset() {
    final last = _lastActivityAt;
    if (last != null &&
        DateTime.now().difference(last) > _retentionWindow &&
        !state.isStreaming) {
      startNewChat();
    }
  }

  /// Bắt đầu hội thoại mới (nút reset trên màn chat).
  void startNewChat() {
    _sub?.cancel();
    _lastActivityAt = null;
    emit(const AiChatState());
  }

  Future<void> send(String text) async {
    final message = text.trim();
    if (message.isEmpty || state.isStreaming) return;
    _lastActivityAt = DateTime.now();

    // Lịch sử = các lượt đã hoàn tất, cắt còn [_maxHistoryMessages] tin gần nhất.
    final completed = state.messages;
    final recent = completed.length > _maxHistoryMessages
        ? completed.sublist(completed.length - _maxHistoryMessages)
        : completed;
    final history = List<ChatMessage>.unmodifiable(recent);
    final withUser = [
      ...state.messages,
      ChatMessage(role: ChatRole.user, content: message),
      const ChatMessage(role: ChatRole.assistant, content: '', isStreaming: true),
    ];
    emit(state.copyWith(messages: withUser, isStreaming: true, clearError: true));

    final buffer = StringBuffer();
    await _sub?.cancel();
    _sub = _streamReply(message: message, history: history).listen(
      (delta) {
        buffer.write(delta);
        _applyBuffer(buffer.toString(), isStreaming: true);
      },
      onError: _onStreamError,
      onDone: () {
        if (_displayText(buffer.toString()).trim().isEmpty) {
          _updateLastAssistant(
            'Xin lỗi, mình chưa có câu trả lời. Bạn thử hỏi lại nhé.',
            isStreaming: false,
          );
        } else {
          _applyBuffer(buffer.toString(), isStreaming: false);
        }
        _lastActivityAt = DateTime.now();
        emit(state.copyWith(isStreaming: false));
      },
      cancelOnError: true,
    );
  }

  /// Phần văn bản hiển thị = mọi thứ TRƯỚC sentinel metadata xe.
  String _displayText(String raw) {
    final idx = raw.indexOf(_refsSentinel);
    return idx == -1 ? raw : raw.substring(0, idx);
  }

  /// Tách buffer thành text hiển thị + danh sách xe (nếu đã tới phần metadata),
  /// rồi cập nhật tin assistant. Metadata đến sau nên khi đang stream có thể chưa
  /// parse được JSON — bỏ qua, tới onDone sẽ đủ.
  void _applyBuffer(String raw, {required bool isStreaming}) {
    final idx = raw.indexOf(_refsSentinel);
    final text = idx == -1 ? raw : raw.substring(0, idx);
    final vehicles = idx == -1
        ? const <VehicleRef>[]
        : _parseVehicles(raw.substring(idx + _refsSentinel.length));
    _updateLastAssistant(text, isStreaming: isStreaming, vehicles: vehicles);
  }

  List<VehicleRef> _parseVehicles(String jsonPart) {
    try {
      final decoded = jsonDecode(jsonPart);
      final list = decoded is Map && decoded['vehicles'] is List
          ? decoded['vehicles'] as List
          : const [];
      return list
          .whereType<Map>()
          .map(
            (m) => VehicleRef(id: '${m['id'] ?? ''}', name: '${m['name'] ?? ''}'),
          )
          .where((v) => v.id.isNotEmpty && v.name.isNotEmpty)
          .toList();
    } on FormatException {
      return const []; // JSON chưa đủ (đang stream) — sẽ parse lại ở onDone.
    }
  }

  void _onStreamError(Object error) {
    final message = error is ApiException
        ? error.message
        : 'Đã xảy ra lỗi khi nói chuyện với trợ lý AI.';
    // Bỏ tin assistant rỗng đang chờ, hiển thị lỗi qua banner.
    final trimmed = [...state.messages]..removeWhere(
      (m) => m.role == ChatRole.assistant && m.content.isEmpty,
    );
    emit(state.copyWith(messages: trimmed, isStreaming: false, error: message));
  }

  void _updateLastAssistant(
    String content, {
    required bool isStreaming,
    List<VehicleRef> vehicles = const [],
  }) {
    if (state.messages.isEmpty) return;
    final updated = [...state.messages];
    final last = updated.last;
    if (last.role != ChatRole.assistant) return;
    updated[updated.length - 1] = last.copyWith(
      content: content,
      isStreaming: isStreaming,
      vehicles: vehicles,
    );
    emit(state.copyWith(messages: updated));
  }

  void clearError() => emit(state.copyWith(clearError: true));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
