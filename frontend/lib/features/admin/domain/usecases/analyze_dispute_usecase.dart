import 'package:frontend/features/admin/domain/entities/admin_dispute_analysis.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class AnalyzeDisputeUseCase {
  const AnalyzeDisputeUseCase(this._repository);

  final AdminRepository _repository;

  Future<DisputeAnalysis> call(String id) => _repository.analyzeDispute(id);
}
