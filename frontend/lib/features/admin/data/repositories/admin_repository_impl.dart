import 'package:frontend/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:frontend/features/admin/data/models/admin_kyc_item_model.dart';
import 'package:frontend/features/admin/data/models/admin_stats_model.dart';
import 'package:frontend/features/admin/data/models/admin_user_item_model.dart';
import 'package:frontend/features/admin/domain/entities/admin_kyc_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_stats.dart';
import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._remote);

  final AdminRemoteDataSource _remote;

  @override
  Future<AdminStats> getStats() async =>
      AdminStatsModel.fromJson(await _remote.stats());

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
}
