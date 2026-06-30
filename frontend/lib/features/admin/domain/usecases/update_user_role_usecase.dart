import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class UpdateUserRoleUseCase {
  const UpdateUserRoleUseCase(this._repository);

  final AdminRepository _repository;

  Future<AdminUserItem> call(
    String id, {
    required String role,
    required String action,
  }) => _repository.updateUserRole(id, role: role, action: action);
}
