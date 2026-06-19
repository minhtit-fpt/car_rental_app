import 'package:frontend/features/loyalty/data/datasources/loyalty_remote_datasource.dart';
import 'package:frontend/features/loyalty/data/models/loyalty_model.dart';
import 'package:frontend/features/loyalty/domain/entities/loyalty.dart';
import 'package:frontend/features/loyalty/domain/repositories/loyalty_repository.dart';

class LoyaltyRepositoryImpl implements LoyaltyRepository {
  const LoyaltyRepositoryImpl(this._remote);

  final LoyaltyRemoteDataSource _remote;

  @override
  Future<LoyaltySummary> getSummary({int page = 1, int limit = 20}) async =>
      LoyaltyModel.fromJson(await _remote.getSummary(page: page, limit: limit));
}
