import 'package:frontend/features/owner/domain/entities/owner_booking.dart';
import 'package:frontend/features/owner/domain/repositories/owner_repository.dart';

/// Chủ xe chấp nhận yêu cầu đặt (`POST /api/bookings/:id/approve`).
class ApproveBookingUseCase {
  const ApproveBookingUseCase(this._repository);

  final OwnerRepository _repository;

  Future<OwnerBooking> call(String id) => _repository.approve(id);
}
