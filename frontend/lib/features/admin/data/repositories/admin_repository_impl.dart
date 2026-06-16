import 'package:frontend/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:frontend/features/admin/data/models/admin_stats_model.dart';
import 'package:frontend/features/admin/domain/entities/admin_stats.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._remote);

  final AdminRemoteDataSource _remote;

  @override
  Future<AdminStats> getStats() async =>
      AdminStatsModel.fromJson(await _remote.stats());
}
