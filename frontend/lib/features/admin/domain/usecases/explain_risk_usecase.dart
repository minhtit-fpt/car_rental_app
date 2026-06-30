import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

/// 5b-tail: lấy lời giải thích AI cho một user bị cờ rủi ro. `explanation` null
/// khi LM Studio offline (kèm `aiError`).
class ExplainRiskUseCase {
  const ExplainRiskUseCase(this._repository);

  final AdminRepository _repository;

  Future<({String? explanation, String? aiError})> call(String userId) =>
      _repository.explainRisk(userId);
}
