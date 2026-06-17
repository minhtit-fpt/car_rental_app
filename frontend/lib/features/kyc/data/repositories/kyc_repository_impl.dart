import 'package:frontend/features/kyc/data/datasources/kyc_remote_datasource.dart';
import 'package:frontend/features/kyc/data/models/kyc_status_info_model.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';
import 'package:frontend/features/kyc/domain/repositories/kyc_repository.dart';

class KycRepositoryImpl implements KycRepository {
  const KycRepositoryImpl(this._remote);

  final KycRemoteDataSource _remote;

  @override
  Future<KycStatusInfo> getStatus() async =>
      KycStatusInfoModel.fromJson(await _remote.status());
}
