import 'package:frontend/features/admin/domain/entities/kyc_documents.dart';

/// Trạng thái màn duyệt KYC: tải ảnh giấy tờ + thực hiện duyệt/từ chối.
class AdminKycDetailState {
  const AdminKycDetailState({
    this.documents,
    this.loadingDocs = true,
    this.docsError,
    this.submitting = false,
    this.reviewError,
    this.reviewDone = false,
  });

  final KycDocuments? documents;
  final bool loadingDocs;
  final String? docsError;

  /// true khi đang gửi quyết định duyệt/từ chối.
  final bool submitting;
  final String? reviewError;

  /// true khi duyệt/từ chối thành công → màn pop + refresh hàng đợi.
  final bool reviewDone;

  AdminKycDetailState copyWith({
    KycDocuments? documents,
    bool? loadingDocs,
    String? docsError,
    bool? submitting,
    String? reviewError,
    bool? reviewDone,
  }) {
    return AdminKycDetailState(
      documents: documents ?? this.documents,
      loadingDocs: loadingDocs ?? this.loadingDocs,
      docsError: docsError,
      submitting: submitting ?? this.submitting,
      reviewError: reviewError,
      reviewDone: reviewDone ?? this.reviewDone,
    );
  }
}
