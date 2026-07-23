import 'package:frontend/features/booking/domain/entities/booking.dart';
import 'package:frontend/features/owner/domain/entities/owner_booking.dart';
import 'package:frontend/features/owner/domain/entities/owner_revenue.dart';

/// Hợp đồng domain cho dữ liệu chủ xe (`/api/owner/*` + phê duyệt đơn).
abstract interface class OwnerRepository {
  /// `GET /api/owner/bookings` — đơn đặt trên các xe của chủ xe.
  Future<List<OwnerBooking>> listBookings({
    BookingStatus? status,
    int page,
    int limit,
  });

  /// `GET /api/owner/bookings/:id` — chi tiết 1 đơn (vd mở từ thông báo).
  Future<OwnerBooking> getBookingById(String id);

  /// `POST /api/bookings/:id/approve` — chấp nhận yêu cầu.
  Future<OwnerBooking> approve(String id);

  /// `POST /api/bookings/:id/reject` — từ chối yêu cầu.
  Future<OwnerBooking> reject(String id);

  /// `GET /api/owner/revenue` — tổng quan doanh thu.
  Future<OwnerRevenue> getRevenue({int months});
}
