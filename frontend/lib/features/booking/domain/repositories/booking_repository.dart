import 'package:frontend/features/booking/domain/entities/booking.dart';

/// Hợp đồng domain cho dữ liệu đơn đặt (`/api/bookings*`).
abstract interface class BookingRepository {
  /// `POST /api/bookings` — tạo đơn mới (cần KYC VERIFIED). Trả đơn ở trạng thái
  /// `PENDING_PAYMENT` cùng `totalPrice` do backend tính.
  Future<Booking> createBooking({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
    bool deliveryRequested,
  });

  /// `GET /api/bookings` — danh sách đơn của chính người dùng.
  Future<List<Booking>> listBookings({
    BookingStatus? status,
    int page,
    int limit,
  });

  /// `GET /api/bookings/:id` — chi tiết một đơn (chỉ chủ đơn).
  Future<Booking> getBooking(String id);

  /// `POST /api/bookings/:id/cancel` — huỷ đơn.
  Future<Booking> cancelBooking(String id);
}
