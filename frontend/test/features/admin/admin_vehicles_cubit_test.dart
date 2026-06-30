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
import 'package:frontend/features/admin/domain/entities/admin_booking_detail.dart';
import 'package:frontend/features/admin/domain/entities/admin_booking_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_risk_item.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:frontend/features/admin/domain/entities/admin_analytics_answer.dart';
import 'package:frontend/features/admin/domain/entities/admin_dispute_analysis.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_vehicles_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/review_vehicle_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_vehicles_cubit.dart';

class _FakeAdminRepository implements AdminRepository {
  @override
  Future<({String? explanation, String? aiError})> explainRisk(String userId) => throw UnimplementedError();
  @override
  Future<DisputeAnalysis> analyzeDispute(String id) => throw UnimplementedError();
  @override
  Future<AnalyticsAnswer> askAnalytics(String question) => throw UnimplementedError();
  @override
  Future<List<AdminRiskItem>> listRiskFlags() => throw UnimplementedError();
  @override
  Future<List<AdminBookingItem>> listBookings({String? status, int limit = 50}) =>
      throw UnimplementedError();
  @override
  Future<AdminBookingDetail> getBookingDetail(String id) =>
      throw UnimplementedError();
  @override
  Future<void> refundPayment(
    String id, {
    required double amount,
    required String reason,
  }) => throw UnimplementedError();
  Object? listError;
  Object? reviewError;
  String? lastDecision;
  String? lastReason;
  List<AdminVehicleItem> items = const [];

  @override
  Future<List<AdminVehicleItem>> listVehiclesForReview({
    String status = 'PENDING',
    int limit = 50,
  }) async {
    if (listError != null) throw listError!;
    return items;
  }

  @override
  Future<void> reviewVehicle(
    String id, {
    required String decision,
    String? rejectionReason,
  }) async {
    lastDecision = decision;
    lastReason = rejectionReason;
    if (reviewError != null) throw reviewError!;
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
  Future<AdminUserItem> updateUserRole(
    String id, {
    required String role,
    required String action,
  }) => throw UnimplementedError();
}

AdminVehiclesCubit _cubit(_FakeAdminRepository repo) => AdminVehiclesCubit(
  listVehicles: ListAdminVehiclesUseCase(repo),
  reviewVehicle: ReviewVehicleUseCase(repo),
);

AdminVehicleItem _vehicle() => AdminVehicleItem(
  id: 'v1',
  title: 'Tesla',
  type: 'CAR',
  pricePerHour: 100000,
  isElectric: true,
  approvalStatus: 'PENDING',
  createdAt: DateTime(2026, 1, 1),
  ownerId: 'o1',
  ownerPhone: '0900000000',
);

void main() {
  group('AdminVehiclesCubit', () {
    test('load success → Loaded với items', () async {
      final repo = _FakeAdminRepository()..items = [_vehicle()];
      final cubit = _cubit(repo);

      await cubit.load();

      expect(cubit.state, isA<AdminVehiclesLoaded>());
      expect((cubit.state as AdminVehiclesLoaded).items, hasLength(1));
    });

    test('load error → Error', () async {
      final repo = _FakeAdminRepository()
        ..listError = const ApiException('lỗi mạng');
      final cubit = _cubit(repo);

      await cubit.load();

      expect(cubit.state, isA<AdminVehiclesError>());
    });

    test('review approve → gọi repo, trả null + reload', () async {
      final repo = _FakeAdminRepository()..items = [_vehicle()];
      final cubit = _cubit(repo);

      final err = await cubit.review('v1', decision: 'approve');

      expect(err, isNull);
      expect(repo.lastDecision, 'approve');
      expect(cubit.state, isA<AdminVehiclesLoaded>());
    });

    test('review lỗi → trả message, không ném', () async {
      final repo = _FakeAdminRepository()
        ..reviewError = const ApiException('không duyệt được');
      final cubit = _cubit(repo);

      final err = await cubit.review(
        'v1',
        decision: 'reject',
        rejectionReason: 'Ảnh mờ',
      );

      expect(err, 'không duyệt được');
      expect(repo.lastReason, 'Ảnh mờ');
    });
  });
}
