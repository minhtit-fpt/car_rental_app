import 'package:frontend/features/admin/domain/entities/admin_kyc_item.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class ListAdminKycUseCase {
  const ListAdminKycUseCase(this._repository);

  final AdminRepository _repository;

  Future<List<AdminKycItem>> call({int limit = 50}) =>
      _repository.listKycQueue(limit: limit);
}
