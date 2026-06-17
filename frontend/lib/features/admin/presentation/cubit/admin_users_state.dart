import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';

sealed class AdminUsersState {
  const AdminUsersState();
}

final class AdminUsersLoading extends AdminUsersState {
  const AdminUsersLoading();
}

final class AdminUsersLoaded extends AdminUsersState {
  const AdminUsersLoaded(this.items);
  final List<AdminUserItem> items;
}

final class AdminUsersError extends AdminUsersState {
  const AdminUsersError(this.message);
  final String message;
}
