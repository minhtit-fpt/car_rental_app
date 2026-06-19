import 'package:frontend/features/booking/domain/entities/booking.dart';

/// Đơn đặt nhìn từ phía chủ xe — kèm thông tin xe + người thuê.
/// Phản chiếu `OwnerBooking` của backend (`/api/owner/bookings`).
class OwnerBooking {
  const OwnerBooking({
    required this.id,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.deliveryRequested,
    required this.createdAt,
    required this.vehicleId,
    required this.vehicleTitle,
    required this.vehicleType,
    required this.renterId,
    required this.renterPhone,
    required this.renterEmail,
  });

  final String id;
  final BookingStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final bool deliveryRequested;
  final DateTime createdAt;

  final String vehicleId;
  final String vehicleTitle;
  final String vehicleType;

  final String renterId;
  final String renterPhone;
  final String? renterEmail;

  /// Đơn đang chờ chủ xe xác nhận (có thể chấp nhận/từ chối).
  bool get isPending => status == BookingStatus.pendingPayment;

  /// Tên hiển thị người thuê (backend chưa có field name → dùng email/phone).
  String get renterDisplayName => renterEmail ?? renterPhone;
}
