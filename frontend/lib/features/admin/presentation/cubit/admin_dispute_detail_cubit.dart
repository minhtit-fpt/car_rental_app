import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/analyze_dispute_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/resolve_dispute_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_dispute_detail_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_dispute_detail_state.dart';

/// Cubit cho một tranh chấp: giải quyết (resolve) hoặc bác bỏ (reject) + trợ lý
/// AI (Phase 4, advisory — không tự đổi tiền/trạng thái).
class AdminDisputeDetailCubit extends Cubit<AdminDisputeDetailState> {
  AdminDisputeDetailCubit({
    required String disputeId,
    required ResolveDisputeUseCase resolveDispute,
    required AnalyzeDisputeUseCase analyzeDispute,
  }) : _disputeId = disputeId,
       _resolveDispute = resolveDispute,
       _analyzeDispute = analyzeDispute,
       super(const AdminDisputeDetailState());

  final String _disputeId;
  final ResolveDisputeUseCase _resolveDispute;
  final AnalyzeDisputeUseCase _analyzeDispute;

  /// Gọi trợ lý AI phân tích tranh chấp (lazy, không cache phía BE).
  Future<void> analyze() async {
    if (state.analyzing) return;
    emit(state.copyWith(analyzing: true, analyzeError: null));
    try {
      final result = await _analyzeDispute(_disputeId);
      emit(state.copyWith(analyzing: false, analysis: result));
    } on ApiException catch (e) {
      emit(state.copyWith(analyzing: false, analyzeError: e.message));
    }
  }

  Future<void> resolve({String? note}) =>
      _submit(decision: 'resolve', note: note);

  Future<void> reject({String? note}) =>
      _submit(decision: 'reject', note: note);

  Future<void> _submit({required String decision, String? note}) async {
    if (state.submitting) return;
    emit(state.copyWith(submitting: true, error: null));
    try {
      await _resolveDispute(_disputeId, decision: decision, note: note);
      emit(state.copyWith(submitting: false, done: true));
    } on ApiException catch (e) {
      emit(state.copyWith(submitting: false, error: e.message));
    }
  }
}
