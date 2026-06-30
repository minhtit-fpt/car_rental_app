/// Trạng thái màn xử lý một tranh chấp: gửi quyết định resolve/reject.
class AdminDisputeDetailState {
  const AdminDisputeDetailState({
    this.submitting = false,
    this.error,
    this.done = false,
  });

  final bool submitting;
  final String? error;

  /// true khi xử lý thành công → màn pop + refresh hàng đợi.
  final bool done;

  AdminDisputeDetailState copyWith({
    bool? submitting,
    String? error,
    bool? done,
  }) {
    return AdminDisputeDetailState(
      submitting: submitting ?? this.submitting,
      error: error,
      done: done ?? this.done,
    );
  }
}
