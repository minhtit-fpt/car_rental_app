import 'package:equatable/equatable.dart';

/// Trạng thái đơn — khớp enum backend.
enum BookingStatus {
  pendingPayment,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

BookingStatus bookingStatusFromWire(String? value) => switch (value) {
      'CONFIRMED' => BookingStatus.confirmed,
      'IN_PROGRESS' => BookingStatus.inProgress,
      'COMPLETED' => BookingStatus.completed,
      'CANCELLED' => BookingStatus.cancelled,
      _ => BookingStatus.pendingPayment,
    };

extension BookingStatusX on BookingStatus {
  String get label => switch (this) {
        BookingStatus.pendingPayment => 'Chờ thanh toán',
        BookingStatus.confirmed => 'Đã xác nhận',
        BookingStatus.inProgress => 'Đang thuê',
        BookingStatus.completed => 'Hoàn tất',
        BookingStatus.cancelled => 'Đã huỷ',
      };

  /// Trạng thái còn được phép huỷ (khớp CANCELLABLE bên service backend).
  bool get isCancellable =>
      this == BookingStatus.pendingPayment || this == BookingStatus.confirmed;
}

/// Đơn đặt xe — khớp PublicBooking trả về từ backend.
class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.vehicleId,
    required this.renterId,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.deliveryRequested,
    required this.createdAt,
  });

  final String id;
  final String vehicleId;
  final String renterId;
  final BookingStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final bool deliveryRequested;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        renterId,
        status,
        startTime,
        endTime,
        totalPrice,
        deliveryRequested,
        createdAt,
      ];
}
