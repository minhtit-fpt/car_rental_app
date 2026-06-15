import 'package:frontend/features/admin/domain/entities/admin_stats.dart';

/// Hợp đồng domain cho dữ liệu quản trị. Chỉ ADMIN gọi được (backend chặn role).
abstract interface class AdminRepository {
  Future<AdminStats> getStats();
}
