import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/usecases/explain_risk_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/list_risk_flags_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_risk_state.dart';

export 'package:frontend/features/admin/presentation/cubit/admin_risk_state.dart';

/// Hàng đợi tài khoản bị cờ rủi ro (rule-engine, chỉ đọc) + giải thích AI
/// (5b-tail, advisory).
class AdminRiskCubit extends Cubit<AdminRiskState> {
  AdminRiskCubit({
    required ListRiskFlagsUseCase listRiskFlags,
    required ExplainRiskUseCase explainRisk,
  }) : _listRiskFlags = listRiskFlags,
       _explainRisk = explainRisk,
       super(const AdminRiskLoading());

  final ListRiskFlagsUseCase _listRiskFlags;
  final ExplainRiskUseCase _explainRisk;

  Future<void> load() async {
    emit(const AdminRiskLoading());
    try {
      emit(AdminRiskLoaded(await _listRiskFlags()));
    } on ApiException catch (e) {
      emit(AdminRiskError(e.message));
    }
  }

  /// Lấy lời giải thích AI cho một user bị cờ. Offline → hiện thông báo lỗi.
  Future<void> explain(String userId) async {
    final current = state;
    if (current is! AdminRiskLoaded) return;
    if (current.explainingUserId != null) return;
    emit(current.copyWith(explainingUserId: userId));
    try {
      final r = await _explainRisk(userId);
      final text =
          r.explanation ?? r.aiError ?? 'Chưa tạo được giải thích.';
      emit(
        current.copyWith(
          explanations: {...current.explanations, userId: text},
          explainingUserId: null,
        ),
      );
    } on ApiException catch (e) {
      emit(
        current.copyWith(
          explanations: {...current.explanations, userId: e.message},
          explainingUserId: null,
        ),
      );
    }
  }
}
