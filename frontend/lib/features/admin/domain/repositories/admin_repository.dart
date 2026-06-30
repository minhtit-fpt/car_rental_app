import 'package:frontend/features/admin/domain/entities/admin_dispute_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_kyc_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_metrics.dart';
import 'package:frontend/features/admin/domain/entities/admin_revenue_point.dart';
import 'package:frontend/features/admin/domain/entities/admin_stats.dart';
import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_vehicle_item.dart';
import 'package:frontend/features/admin/domain/entities/kyc_documents.dart';

/// Hợp đồng domain cho dữ liệu quản trị. Chỉ ADMIN gọi được (backend chặn role).
abstract interface class AdminRepository {
  Future<AdminStats> getStats();

  Future<AdminMetrics> getMetrics();

  Future<List<AdminUserItem>> listUsers({int limit});

  Future<List<AdminKycItem>> listKycQueue({int limit});

  Future<KycDocuments> getKycDocuments(String id);

  Future<void> reviewKyc(
    String id, {
    required String decision,
    String? rejectReason,
  });

  Future<List<AdminRevenuePoint>> listRevenue({int months});

  Future<List<AdminDisputeItem>> listDisputes({int limit});

  Future<void> resolveDispute(
    String id, {
    required String decision,
    String? note,
  });

  /// Bật/tắt vai trò user (`role` = 'OWNER', `action` ∈ {add, remove}).
  /// Trả về user đã cập nhật.
  Future<AdminUserItem> updateUserRole(
    String id, {
    required String role,
    required String action,
  });

  Future<List<AdminVehicleItem>> listVehiclesForReview({
    String status,
    int limit,
  });

  Future<void> reviewVehicle(
    String id, {
    required String decision,
    String? rejectionReason,
  });
}
