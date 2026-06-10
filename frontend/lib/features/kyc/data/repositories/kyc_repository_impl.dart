import 'dart:io';

import 'package:frontend/features/kyc/data/datasources/kyc_remote_datasource.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_doc_type.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';
import 'package:frontend/features/kyc/domain/repositories/kyc_repository.dart';

class KycRepositoryImpl implements KycRepository {
  const KycRepositoryImpl(this._remote);

  final KycRemoteDataSource _remote;

  @override
  Future<KycStatusInfo> getStatus() => _remote.getStatus();

  @override
  Future<String> uploadDocument({
    required KycDocType docType,
    required File file,
  }) =>
      _remote.uploadDocument(docType: docType, file: file);

  @override
  Future<KycStatusInfo> submit({
    required String cccdKey,
    required String licenseKey,
    required String faceKey,
  }) =>
      _remote.submit(
        cccdKey: cccdKey,
        licenseKey: licenseKey,
        faceKey: faceKey,
      );
}
