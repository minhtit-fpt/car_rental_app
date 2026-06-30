import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/get_kyc_documents_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/review_kyc_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_kyc_detail_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_kyc_detail_state.dart';

/// Cubit cho một hồ sơ KYC: tải ảnh giấy tờ + duyệt/từ chối.
class AdminKycDetailCubit extends Cubit<AdminKycDetailState> {
  AdminKycDetailCubit({
    required String kycId,
    required GetKycDocumentsUseCase getDocuments,
    required ReviewKycUseCase reviewKyc,
  }) : _kycId = kycId,
       _getDocuments = getDocuments,
       _reviewKyc = reviewKyc,
       super(const AdminKycDetailState());

  final String _kycId;
  final GetKycDocumentsUseCase _getDocuments;
  final ReviewKycUseCase _reviewKyc;

  Future<void> loadDocuments() async {
    emit(state.copyWith(loadingDocs: true, docsError: null));
    try {
      final docs = await _getDocuments(_kycId);
      emit(state.copyWith(documents: docs, loadingDocs: false));
    } on ApiException catch (e) {
      emit(state.copyWith(loadingDocs: false, docsError: e.message));
    }
  }

  /// Duyệt hồ sơ. Thành công → `reviewDone = true`.
  Future<void> approve() => _submit(decision: 'approve');

  /// Từ chối hồ sơ kèm lý do (bắt buộc, backend ràng buộc).
  Future<void> reject(String reason) =>
      _submit(decision: 'reject', rejectReason: reason);

  Future<void> _submit({required String decision, String? rejectReason}) async {
    if (state.submitting) return;
    emit(state.copyWith(submitting: true, reviewError: null));
    try {
      await _reviewKyc(_kycId, decision: decision, rejectReason: rejectReason);
      emit(state.copyWith(submitting: false, reviewDone: true));
    } on ApiException catch (e) {
      emit(state.copyWith(submitting: false, reviewError: e.message));
    }
  }
}
