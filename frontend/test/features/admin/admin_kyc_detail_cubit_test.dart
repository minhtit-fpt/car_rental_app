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
import 'package:frontend/features/admin/domain/usecases/get_kyc_documents_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/review_kyc_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_kyc_detail_cubit.dart';

/// Fake cấu hình được — chỉ hiện thực 2 method KYC detail cần.
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
  KycDocuments? docsResult;
  Object? docsError;
  Object? reviewError;

  String? lastDecision;
  String? lastReason;

  @override
  Future<KycDocuments> getKycDocuments(String id) async {
    if (docsError != null) throw docsError!;
    return docsResult!;
  }

  @override
  Future<void> reviewKyc(
    String id, {
    required String decision,
    String? rejectReason,
  }) async {
    lastDecision = decision;
    lastReason = rejectReason;
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

const _docs = KycDocuments(
  cccdUrl: 'https://x/cccd',
  licenseUrl: 'https://x/license',
  faceUrl: 'https://x/face',
);

AdminKycDetailCubit _cubit(_FakeAdminRepository repo) => AdminKycDetailCubit(
  kycId: 'kyc1',
  getDocuments: GetKycDocumentsUseCase(repo),
  reviewKyc: ReviewKycUseCase(repo),
);

void main() {
  group('AdminKycDetailCubit', () {
    test('loadDocuments success → documents set, loadingDocs false', () async {
      final repo = _FakeAdminRepository()..docsResult = _docs;
      final cubit = _cubit(repo);

      await cubit.loadDocuments();

      expect(cubit.state.documents, _docs);
      expect(cubit.state.loadingDocs, isFalse);
      expect(cubit.state.docsError, isNull);
    });

    test('loadDocuments error → docsError set', () async {
      final repo = _FakeAdminRepository()
        ..docsError = const ApiException('hết hạn');
      final cubit = _cubit(repo);

      await cubit.loadDocuments();

      expect(cubit.state.docsError, 'hết hạn');
      expect(cubit.state.loadingDocs, isFalse);
    });

    test('approve → gửi decision=approve, reviewDone true', () async {
      final repo = _FakeAdminRepository();
      final cubit = _cubit(repo);

      await cubit.approve();

      expect(repo.lastDecision, 'approve');
      expect(repo.lastReason, isNull);
      expect(cubit.state.reviewDone, isTrue);
    });

    test('reject → truyền reason xuống, reviewDone true', () async {
      final repo = _FakeAdminRepository();
      final cubit = _cubit(repo);

      await cubit.reject('Ảnh mờ');

      expect(repo.lastDecision, 'reject');
      expect(repo.lastReason, 'Ảnh mờ');
      expect(cubit.state.reviewDone, isTrue);
    });

    test('review error → reviewError set, reviewDone false', () async {
      final repo = _FakeAdminRepository()
        ..reviewError = const ApiException('lỗi mạng');
      final cubit = _cubit(repo);

      await cubit.approve();

      expect(cubit.state.reviewError, 'lỗi mạng');
      expect(cubit.state.reviewDone, isFalse);
    });
  });
}
