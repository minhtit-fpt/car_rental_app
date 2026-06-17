import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';

class CreateBookingUseCase {
  const CreateBookingUseCase(this._repository);

  final BookingRepository _repository;

  Future<Booking> call({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
    bool deliveryRequested = false,
  }) => _repository.createBooking(
    vehicleId: vehicleId,
    startTime: startTime,
    endTime: endTime,
    deliveryRequested: deliveryRequested,
  );
}
