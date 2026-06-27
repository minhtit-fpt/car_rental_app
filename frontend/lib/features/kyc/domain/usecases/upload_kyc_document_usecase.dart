import 'package:frontend/features/kyc/domain/repositories/kyc_repository.dart';

/// Upload một ảnh giấy tờ KYC, trả về `objectKey` để dùng khi submit.
class UploadKycDocumentUseCase {
  const UploadKycDocumentUseCase(this._repository);

  final KycRepository _repository;

  Future<String> call({
    required String docType,
    required List<int> bytes,
    required String contentType,
  }) => _repository.uploadDocument(
    docType: docType,
    bytes: bytes,
    contentType: contentType,
  );
}
