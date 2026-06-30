import 'package:frontend/features/admin/domain/entities/admin_booking_item.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';

class ListAdminBookingsUseCase {
  const ListAdminBookingsUseCase(this._repository);

  final AdminRepository _repository;

  Future<List<AdminBookingItem>> call({String? status}) =>
      _repository.listBookings(status: status);
}
