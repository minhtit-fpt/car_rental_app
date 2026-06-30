import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class ResolveDisputeUseCase {
  const ResolveDisputeUseCase(this._repository);

  final AdminRepository _repository;

  Future<void> call(String id, {required String decision, String? note}) =>
      _repository.resolveDispute(id, decision: decision, note: note);
}
