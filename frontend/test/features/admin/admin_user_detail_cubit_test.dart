import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/admin/domain/entities/admin_dispute_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_kyc_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_metrics.dart';
import 'package:frontend/features/admin/domain/entities/admin_revenue_point.dart';
import 'package:frontend/features/admin/domain/entities/admin_stats.dart';
import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_vehicle_item.dart';
import 'package:frontend/features/admin/domain/entities/kyc_documents.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:frontend/features/admin/domain/usecases/update_user_role_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_user_detail_cubit.dart';

/// Fake chỉ hiện thực updateUserRole; method khác không dùng → ném.
class _FakeAdminRepository implements AdminRepository {
  Object? error;
  String? lastRole;
  String? lastAction;
  List<String> resultRoles = const ['RENTER'];

  @override
  Future<AdminUserItem> updateUserRole(
    String id, {
    required String role,
    required String action,
  }) async {
    lastRole = role;
    lastAction = action;
    if (error != null) throw error!;
    return AdminUserItem(
      id: id,
      phone: '0900000000',
      roles: resultRoles,
      kycStatus: 'UNVERIFIED',
      createdAt: DateTime(2026, 1, 1),
    );
  }

  @override
  Future<AdminStats> getStats() => throw UnimplementedError();
  @override
  Future<AdminMetrics> getMetrics() => throw UnimplementedError();
  @override
  Future<List<AdminUserItem>> listUsers({int limit = 50}) =>
      throw UnimplementedError();
  @override
  Future<List<AdminKycItem>> listKycQueue({int limit = 50}) =>
      throw UnimplementedError();
  @override
  Future<KycDocuments> getKycDocuments(String id) => throw UnimplementedError();
  @override
  Future<void> reviewKyc(
    String id, {
    required String decision,
    String? rejectReason,
  }) => throw UnimplementedError();
  @override
  Future<List<AdminRevenuePoint>> listRevenue({int months = 6}) =>
      throw UnimplementedError();
  @override
  Future<List<AdminDisputeItem>> listDisputes({int limit = 50}) =>
      throw UnimplementedError();
  @override
  Future<void> resolveDispute(
    String id, {
    required String decision,
    String? note,
  }) => throw UnimplementedError();
  @override
  Future<List<AdminVehicleItem>> listVehiclesForReview({
    String status = 'PENDING',
    int limit = 50,
  }) => throw UnimplementedError();
  @override
  Future<void> reviewVehicle(
    String id, {
    required String decision,
    String? rejectionReason,
  }) => throw UnimplementedError();
}

AdminUserItem _user(List<String> roles) => AdminUserItem(
  id: 'u1',
  phone: '0900000000',
  roles: roles,
  kycStatus: 'UNVERIFIED',
  createdAt: DateTime(2026, 1, 1),
);

AdminUserDetailCubit _cubit(_FakeAdminRepository repo, AdminUserItem user) =>
    AdminUserDetailCubit(
      user: user,
      updateUserRole: UpdateUserRoleUseCase(repo),
    );

void main() {
  group('AdminUserDetailCubit.toggleOwner', () {
    test('RENTER → add OWNER, user cập nhật + changed true', () async {
      final repo = _FakeAdminRepository()
        ..resultRoles = const ['RENTER', 'OWNER'];
      final cubit = _cubit(repo, _user(['RENTER']));

      await cubit.toggleOwner();

      expect(repo.lastAction, 'add');
      expect(repo.lastRole, 'OWNER');
      expect(cubit.state.user.hasOwner, isTrue);
      expect(cubit.state.changed, isTrue);
    });

    test('đang có OWNER → remove', () async {
      final repo = _FakeAdminRepository()..resultRoles = const ['RENTER'];
      final cubit = _cubit(repo, _user(['RENTER', 'OWNER']));

      await cubit.toggleOwner();

      expect(repo.lastAction, 'remove');
      expect(cubit.state.user.hasOwner, isFalse);
    });

    test('lỗi → error set, changed false', () async {
      final repo = _FakeAdminRepository()
        ..error = const ApiException('lỗi mạng');
      final cubit = _cubit(repo, _user(['RENTER']));

      await cubit.toggleOwner();

      expect(cubit.state.error, 'lỗi mạng');
      expect(cubit.state.changed, isFalse);
    });
  });
}
