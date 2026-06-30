import 'package:frontend/features/admin/domain/entities/admin_vehicle_item.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class ListAdminVehiclesUseCase {
  const ListAdminVehiclesUseCase(this._repository);

  final AdminRepository _repository;

  Future<List<AdminVehicleItem>> call({String status = 'PENDING'}) =>
      _repository.listVehiclesForReview(status: status);
}
