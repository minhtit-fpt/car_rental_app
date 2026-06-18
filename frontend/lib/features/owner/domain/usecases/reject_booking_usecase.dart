import 'package:frontend/features/owner/domain/entities/owner_booking.dart';
import 'package:frontend/features/owner/domain/repositories/owner_repository.dart';

/// Chủ xe từ chối yêu cầu đặt (`POST /api/bookings/:id/reject`).
class RejectBookingUseCase {
  const RejectBookingUseCase(this._repository);

  final OwnerRepository _repository;

  Future<OwnerBooking> call(String id) => _repository.reject(id);
}
