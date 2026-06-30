import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';

/// Trạng thái màn chi tiết user: hiển thị user hiện tại + bật/tắt vai OWNER.
class AdminUserDetailState {
  const AdminUserDetailState({
    required this.user,
    this.submitting = false,
    this.error,
    this.changed = false,
  });

  final AdminUserItem user;
  final bool submitting;
  final String? error;

  /// true khi đã đổi vai ít nhất 1 lần → pop trả về để refresh danh sách.
  final bool changed;

  AdminUserDetailState copyWith({
    AdminUserItem? user,
    bool? submitting,
    String? error,
    bool? changed,
  }) {
    return AdminUserDetailState(
      user: user ?? this.user,
      submitting: submitting ?? this.submitting,
      error: error,
      changed: changed ?? this.changed,
    );
  }
}
