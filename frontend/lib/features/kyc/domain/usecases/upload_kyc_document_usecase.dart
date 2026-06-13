import 'dart:io';

import 'package:frontend/features/kyc/domain/entities/kyc_doc_type.dart';
import 'package:frontend/features/kyc/domain/repositories/kyc_repository.dart';

class UploadKycDocumentUseCase {
  const UploadKycDocumentUseCase(this._repository);

  final KycRepository _repository;

  Future<String> call({required KycDocType docType, required File file}) =>
      _repository.uploadDocument(docType: docType, file: file);
}
