import 'package:frontend/features/payment/domain/entities/payment.dart';

abstract interface class PaymentRepository {
  /// Tạo phiên thanh toán cho một đơn (đơn phải ở PENDING_PAYMENT).
  Future<PaymentSession> create(String bookingId);

  /// Mô phỏng callback cổng (mock-first). Thành công → đơn được xác nhận.
  /// Trả về trạng thái thanh toán sau xử lý.
  Future<PaymentStatus> confirm(String paymentId, {required bool success});
}
