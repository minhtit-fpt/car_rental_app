import 'package:frontend/features/admin/domain/entities/admin_kyc_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_stats.dart';
import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';

/// Hợp đồng domain cho dữ liệu quản trị. Chỉ ADMIN gọi được (backend chặn role).
abstract interface class AdminRepository {
  Future<AdminStats> getStats();

  Future<List<AdminUserItem>> listUsers({int limit});

  Future<List<AdminKycItem>> listKycQueue({int limit});
}
