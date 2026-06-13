import 'package:equatable/equatable.dart';
import 'package:frontend/features/booking/domain/entities/booking.dart';

sealed class CreateBookingState extends Equatable {
  const CreateBookingState();

  @override
  List<Object?> get props => [];
}

final class CreateBookingIdle extends CreateBookingState {
  const CreateBookingIdle();
}

final class CreateBookingSubmitting extends CreateBookingState {
  const CreateBookingSubmitting();
}

final class CreateBookingSuccess extends CreateBookingState {
  const CreateBookingSuccess(this.booking);

  final Booking booking;

  @override
  List<Object?> get props => [booking];
}

final class CreateBookingFailure extends CreateBookingState {
  const CreateBookingFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}
