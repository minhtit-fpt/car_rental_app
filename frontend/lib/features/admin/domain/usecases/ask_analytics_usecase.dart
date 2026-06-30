import 'package:frontend/features/admin/domain/entities/admin_analytics_answer.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class AskAnalyticsUseCase {
  const AskAnalyticsUseCase(this._repository);

  final AdminRepository _repository;

  Future<AnalyticsAnswer> call(String question) =>
      _repository.askAnalytics(question);
}
