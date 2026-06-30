import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/resolve_dispute_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_dispute_detail_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_dispute_detail_state.dart';

/// Cubit cho một tranh chấp: giải quyết (resolve) hoặc bác bỏ (reject).
class AdminDisputeDetailCubit extends Cubit<AdminDisputeDetailState> {
  AdminDisputeDetailCubit({
    required String disputeId,
    required ResolveDisputeUseCase resolveDispute,
  }) : _disputeId = disputeId,
       _resolveDispute = resolveDispute,
       super(const AdminDisputeDetailState());

  final String _disputeId;
  final ResolveDisputeUseCase _resolveDispute;

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
