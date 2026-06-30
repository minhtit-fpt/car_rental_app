import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class ReviewKycUseCase {
  const ReviewKycUseCase(this._repository);

  final AdminRepository _repository;

  Future<void> call(
    String id, {
    required String decision,
    String? rejectReason,
  }) =>
      _repository.reviewKyc(id, decision: decision, rejectReason: rejectReason);
}
