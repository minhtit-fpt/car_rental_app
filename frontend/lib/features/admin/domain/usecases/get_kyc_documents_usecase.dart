import 'package:frontend/features/admin/domain/entities/kyc_documents.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class GetKycDocumentsUseCase {
  const GetKycDocumentsUseCase(this._repository);

  final AdminRepository _repository;

  Future<KycDocuments> call(String id) => _repository.getKycDocuments(id);
}
