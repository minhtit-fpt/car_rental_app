import 'package:frontend/features/admin/domain/entities/admin_risk_item.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class ListRiskFlagsUseCase {
  const ListRiskFlagsUseCase(this._repository);

  final AdminRepository _repository;

  Future<List<AdminRiskItem>> call() => _repository.listRiskFlags();
}
