import 'package:frontend/features/admin/domain/entities/admin_booking_detail.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class GetAdminBookingDetailUseCase {
  const GetAdminBookingDetailUseCase(this._repository);

  final AdminRepository _repository;

  Future<AdminBookingDetail> call(String id) =>
      _repository.getBookingDetail(id);
}
