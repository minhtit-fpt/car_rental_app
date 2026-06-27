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

  @override
  Future<String> uploadDocument({
    required String docType,
    required List<int> bytes,
    required String contentType,
  }) async {
    final presign = await _remote.createUploadUrl(
      docType: docType,
      contentType: contentType,
    );
    await _remote.uploadBinary(
      uploadUrl: presign['uploadUrl'] as String,
      bytes: bytes,
      contentType: contentType,
    );
    return presign['objectKey'] as String;
  }

  @override
  Future<void> submitKyc({
    required String cccdKey,
    required String licenseKey,
    required String faceKey,
  }) => _remote.submit(
    cccdKey: cccdKey,
    licenseKey: licenseKey,
    faceKey: faceKey,
  );
}
