import 'package:frontend/features/booking/domain/entities/booking.dart';

enum BookingStep { dates, confirm, contract, active }

class BookingFormState {
  const BookingFormState({
    this.startDate,
    this.endDate,
    this.withDelivery = false,
    this.deliveryAddress = '',
    this.isSubmitting = false,
    this.contractSigned = false,
    this.submitted = false,
    this.booking,
    this.errorMessage,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final bool withDelivery;
  final String deliveryAddress;
  final bool isSubmitting;
  final bool contractSigned;
  final bool submitted;

  /// Đơn đã tạo trên backend (có sau khi [submitted] = true).
  final Booking? booking;

  /// Thông báo lỗi gần nhất khi tạo đơn thất bại (null nếu không có lỗi).
  final String? errorMessage;

  bool get datesSelected => startDate != null && endDate != null;

  int get totalDays {
    if (!datesSelected) return 0;
    return endDate!.difference(startDate!).inDays.clamp(1, 365);
  }

  BookingFormState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? withDelivery,
    String? deliveryAddress,
    bool? isSubmitting,
    bool? contractSigned,
    bool? submitted,
    Booking? booking,
    String? errorMessage,
  }) => BookingFormState(
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    withDelivery: withDelivery ?? this.withDelivery,
    deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    contractSigned: contractSigned ?? this.contractSigned,
    submitted: submitted ?? this.submitted,
    booking: booking ?? this.booking,
    errorMessage: errorMessage,
  );
}
