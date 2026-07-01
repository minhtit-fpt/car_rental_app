/// Câu trả lời NL-analytics. Trợ lý tool-calling ở ai-service trả lời câu hỏi bất
/// kỳ về số liệu; `toolsUsed` là các nguồn dữ liệu (tool admin) đã dùng để trả lời.
class AnalyticsAnswer {
  const AnalyticsAnswer({
    required this.answer,
    this.toolsUsed = const [],
  });

  final String answer;
  final List<String> toolsUsed;
}
