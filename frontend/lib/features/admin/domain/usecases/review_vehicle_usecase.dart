import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class ReviewVehicleUseCase {
  const ReviewVehicleUseCase(this._repository);

  final AdminRepository _repository;

  Future<void> call(
    String id, {
    required String decision,
    String? rejectionReason,
  }) => _repository.reviewVehicle(
    id,
    decision: decision,
    rejectionReason: rejectionReason,
  );
}
