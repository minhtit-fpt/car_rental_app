import 'package:frontend/features/admin/domain/entities/admin_dispute_item.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class ListAdminDisputesUseCase {
  const ListAdminDisputesUseCase(this._repository);

  final AdminRepository _repository;

  Future<List<AdminDisputeItem>> call({int limit = 50}) =>
      _repository.listDisputes(limit: limit);
}
