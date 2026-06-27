import 'package:frontend/features/ai_chat/domain/entities/chat_message.dart';

/// Hợp đồng cho trợ lý AI (RAG chatbot). Trả về **stream** các đoạn văn bản để UI
/// hiển thị dần (giảm cảm giác chờ — nút thắt là LLM local).
abstract interface class AiChatRepository {
  /// Gửi [message] kèm [history] (các lượt trước), nhận về luồng delta văn bản.
  /// Stream kết thúc khi LLM trả lời xong; ném [ApiException] khi lỗi mạng/service.
  Stream<String> streamReply({
    required String message,
    required List<ChatMessage> history,
  });
}
