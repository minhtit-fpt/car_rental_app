/// Câu trả lời NL-analytics (Phase 5a). `templateKey` null = không khớp template
/// hoặc AI offline. `data` là lát số liệu thô để FE tái dùng nếu cần.
class AnalyticsAnswer {
  const AnalyticsAnswer({
    required this.answer,
    this.templateKey,
    this.data,
  });

  final String answer;
  final String? templateKey;
  final Object? data;
}
