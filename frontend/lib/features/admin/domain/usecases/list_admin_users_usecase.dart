import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class ListAdminUsersUseCase {
  const ListAdminUsersUseCase(this._repository);

  final AdminRepository _repository;

  Future<List<AdminUserItem>> call({int limit = 50}) =>
      _repository.listUsers(limit: limit);
}
