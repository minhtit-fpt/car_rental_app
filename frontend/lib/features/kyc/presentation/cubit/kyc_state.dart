import 'package:equatable/equatable.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';

sealed class KycState extends Equatable {
  const KycState();

  @override
  List<Object?> get props => [];
}

/// Đang tải trạng thái KYC ban đầu.
final class KycLoading extends KycState {
  const KycLoading();
}

/// Không tải được trạng thái — cho phép thử lại.
final class KycLoadFailure extends KycState {
  const KycLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Đã có trạng thái KYC. submitting = đang upload + nộp hồ sơ.
/// error = lỗi của lần nộp gần nhất (hiển thị rồi xóa).
final class KycReady extends KycState {
  const KycReady({
    required this.info,
    this.submitting = false,
    this.error,
  });

  final KycStatusInfo info;
  final bool submitting;
  final String? error;

  KycReady copyWith({
    KycStatusInfo? info,
    bool? submitting,
    String? error,
  }) {
    return KycReady(
      info: info ?? this.info,
      submitting: submitting ?? this.submitting,
      error: error,
    );
  }

  @override
  List<Object?> get props => [info, submitting, error];
}
