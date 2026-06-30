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
import 'package:frontend/features/admin/domain/usecases/resolve_dispute_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_dispute_detail_cubit.dart';

/// Fake chỉ hiện thực resolveDispute; method khác không dùng → ném.
class _FakeAdminRepository implements AdminRepository {
  Object? error;
  String? lastDecision;
  String? lastNote;

  @override
  Future<void> resolveDispute(
    String id, {
    required String decision,
    String? note,
  }) async {
    lastDecision = decision;
    lastNote = note;
    if (error != null) throw error!;
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
  Future<AdminUserItem> updateUserRole(
    String id, {
    required String role,
    required String action,
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

AdminDisputeDetailCubit _cubit(_FakeAdminRepository repo) =>
    AdminDisputeDetailCubit(
      disputeId: 'd1',
      resolveDispute: ResolveDisputeUseCase(repo),
    );

void main() {
  group('AdminDisputeDetailCubit', () {
    test('resolve → decision=resolve, note truyền xuống, done true', () async {
      final repo = _FakeAdminRepository();
      final cubit = _cubit(repo);

      await cubit.resolve(note: 'OK');

      expect(repo.lastDecision, 'resolve');
      expect(repo.lastNote, 'OK');
      expect(cubit.state.done, isTrue);
    });

    test('reject → decision=reject, done true', () async {
      final repo = _FakeAdminRepository();
      final cubit = _cubit(repo);

      await cubit.reject();

      expect(repo.lastDecision, 'reject');
      expect(cubit.state.done, isTrue);
    });

    test('lỗi → error set, done false', () async {
      final repo = _FakeAdminRepository()
        ..error = const ApiException('lỗi mạng');
      final cubit = _cubit(repo);

      await cubit.resolve();

      expect(cubit.state.error, 'lỗi mạng');
      expect(cubit.state.done, isFalse);
    });
  });
}
