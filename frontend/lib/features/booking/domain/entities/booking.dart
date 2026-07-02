/// Trạng thái đơn đặt — khớp enum `BookingStatus` của backend (Prisma).
enum BookingStatus {
  pendingPayment,
  awaitingOwner,
  confirmed,
  inProgress,
  completed,
  cancelled,
  unknown;

  /// Ánh xạ chuỗi enum của backend (`PENDING_PAYMENT`, ...) → giá trị Dart.
  static BookingStatus fromApi(String? raw) {
    switch (raw) {
      case 'PENDING_PAYMENT':
        return BookingStatus.pendingPayment;
      case 'AWAITING_OWNER':
        return BookingStatus.awaitingOwner;
      case 'CONFIRMED':
        return BookingStatus.confirmed;
      case 'IN_PROGRESS':
        return BookingStatus.inProgress;
      case 'COMPLETED':
        return BookingStatus.completed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.unknown;
    }
  }
}

/// Đơn đặt xe — phản chiếu `PublicBooking` trả về từ `/api/bookings*`.
class Booking {
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
}
