import 'package:frontend/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:frontend/features/admin/data/models/admin_booking_detail_model.dart';
import 'package:frontend/features/admin/data/models/admin_booking_item_model.dart';
import 'package:frontend/features/admin/data/models/admin_dispute_item_model.dart';
import 'package:frontend/features/admin/data/models/admin_kyc_item_model.dart';
import 'package:frontend/features/admin/data/models/admin_metrics_model.dart';
import 'package:frontend/features/admin/data/models/admin_revenue_point_model.dart';
import 'package:frontend/features/admin/data/models/admin_risk_item_model.dart';
import 'package:frontend/features/admin/data/models/admin_vehicle_item_model.dart';
import 'package:frontend/features/admin/data/models/admin_stats_model.dart';
import 'package:frontend/features/admin/data/models/admin_user_item_model.dart';
import 'package:frontend/features/admin/domain/entities/admin_booking_detail.dart';
import 'package:frontend/features/admin/domain/entities/admin_booking_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_dispute_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_kyc_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_metrics.dart';
import 'package:frontend/features/admin/domain/entities/admin_revenue_point.dart';
import 'package:frontend/features/admin/domain/entities/admin_risk_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_stats.dart';
import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_vehicle_item.dart';
import 'package:frontend/features/admin/domain/entities/kyc_documents.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._remote);

  final AdminRemoteDataSource _remote;

  @override
  Future<AdminStats> getStats() async =>
      AdminStatsModel.fromJson(await _remote.stats());

  @override
  Future<AdminMetrics> getMetrics() async =>
      AdminMetricsModel.fromJson(await _remote.metrics());

  @override
  Future<List<AdminUserItem>> listUsers({int limit = 50}) async {
    final items = await _remote.users(limit: limit);
    return items
        .map((e) => AdminUserItemModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<AdminKycItem>> listKycQueue({int limit = 50}) async {
    final items = await _remote.kyc(limit: limit);
    return items
        .map((e) => AdminKycItemModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<KycDocuments> getKycDocuments(String id) async {
    final json = await _remote.kycDocuments(id);
    return KycDocuments(
      cccdUrl: json['cccdUrl'] as String,
      licenseUrl: json['licenseUrl'] as String,
      faceUrl: json['faceUrl'] as String,
    );
  }

  @override
  Future<void> reviewKyc(
    String id, {
    required String decision,
    String? rejectReason,
  }) => _remote.reviewKyc(id, decision: decision, rejectReason: rejectReason);

  @override
  Future<List<AdminRevenuePoint>> listRevenue({int months = 6}) async {
    final items = await _remote.revenue(months: months);
    return items
        .map((e) => AdminRevenuePointModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<AdminDisputeItem>> listDisputes({int limit = 50}) async {
    final items = await _remote.disputes(limit: limit);
    return items
        .map((e) => AdminDisputeItemModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> resolveDispute(
    String id, {
    required String decision,
    String? note,
  }) => _remote.resolveDispute(id, decision: decision, note: note);

  @override
  Future<AdminUserItem> updateUserRole(
    String id, {
    required String role,
    required String action,
  }) async {
    final json = await _remote.updateUserRole(id, role: role, action: action);
    return AdminUserItemModel.fromJson(json);
  }

  @override
  Future<List<AdminVehicleItem>> listVehiclesForReview({
    String status = 'PENDING',
    int limit = 50,
  }) async {
    final items = await _remote.vehicles(status: status, limit: limit);
    return items
        .map((e) => AdminVehicleItemModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> reviewVehicle(
    String id, {
    required String decision,
    String? rejectionReason,
  }) => _remote.reviewVehicle(
    id,
    decision: decision,
    rejectionReason: rejectionReason,
  );

  @override
  Future<List<AdminBookingItem>> listBookings({
    String? status,
    int limit = 50,
  }) async {
    final items = await _remote.bookings(status: status, limit: limit);
    return items
        .map((e) => AdminBookingItemModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<AdminBookingDetail> getBookingDetail(String id) async =>
      AdminBookingDetailModel.fromJson(await _remote.bookingDetail(id));

  @override
  Future<void> refundPayment(
    String id, {
    required double amount,
    required String reason,
  }) => _remote.refundPayment(id, amount: amount, reason: reason);

  @override
  Future<List<AdminRiskItem>> listRiskFlags() async {
    final items = await _remote.risk();
    return items
        .map((e) => AdminRiskItemModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
