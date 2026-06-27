import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/vehicle/domain/entities/price_quote.dart';

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
    this.priceQuote,
    this.quoteLoading = false,
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

  /// Báo giá động đã tải cho lựa chọn hiện tại (null khi chưa tải/đổi lựa chọn).
  final PriceQuote? priceQuote;

  /// Đang tải báo giá từ backend.
  final bool quoteLoading;

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
    PriceQuote? priceQuote,
    bool? quoteLoading,
    bool resetSubmission = false,
  }) => BookingFormState(
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    withDelivery: withDelivery ?? this.withDelivery,
    deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    contractSigned: contractSigned ?? this.contractSigned,
    submitted: resetSubmission ? false : (submitted ?? this.submitted),
    booking: resetSubmission ? null : (booking ?? this.booking),
    errorMessage: errorMessage,
    // Đổi lựa chọn (resetSubmission) → giá cũ không còn đúng, xoá đi để tải lại.
    priceQuote: resetSubmission ? null : (priceQuote ?? this.priceQuote),
    quoteLoading: quoteLoading ?? this.quoteLoading,
  );
}
