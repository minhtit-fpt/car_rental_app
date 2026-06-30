import 'package:frontend/features/admin/domain/entities/admin_dispute_analysis.dart';

/// Trạng thái màn xử lý một tranh chấp: gửi quyết định resolve/reject + trợ lý
/// AI (Phase 4, advisory).
class AdminDisputeDetailState {
  const AdminDisputeDetailState({
    this.submitting = false,
    this.error,
    this.done = false,
    this.analyzing = false,
    this.analysis,
    this.analyzeError,
  });

  final bool submitting;
  final String? error;

  /// true khi xử lý thành công → màn pop + refresh hàng đợi.
  final bool done;

  /// Trợ lý AI: đang phân tích / kết quả / lỗi gọi phân tích.
  final bool analyzing;
  final DisputeAnalysis? analysis;
  final String? analyzeError;

  AdminDisputeDetailState copyWith({
    bool? submitting,
    String? error,
    bool? done,
    bool? analyzing,
    DisputeAnalysis? analysis,
    String? analyzeError,
  }) {
    return AdminDisputeDetailState(
      submitting: submitting ?? this.submitting,
      error: error,
      done: done ?? this.done,
      analyzing: analyzing ?? this.analyzing,
      analysis: analysis ?? this.analysis,
      analyzeError: analyzeError,
    );
  }
}
