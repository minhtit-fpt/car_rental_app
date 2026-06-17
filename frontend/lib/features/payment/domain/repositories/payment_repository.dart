import 'package:frontend/features/payment/domain/entities/payment.dart';

/// Hợp đồng domain cho thanh toán (`/api/payments*`).
abstract interface class PaymentRepository {
  /// `POST /api/payments` — tạo (hoặc tái dùng) phiên thanh toán cho đơn đang
  /// chờ thanh toán. Trả giao dịch + URL cổng.
  Future<PaymentSession> createPayment(String bookingId);

  /// `GET /api/payments/:id` — chi tiết giao dịch.
  Future<Payment> getPayment(String id);

  /// `POST /api/payments/:id/confirm` — xác nhận callback cổng.
  /// Mock: `success = true`. VNPay thật: truyền `params` (vnp_*) để backend
  /// xác thực chữ ký. Thành công → giao dịch PAID + đơn CONFIRMED.
  Future<Payment> confirmPayment(
    String id, {
    bool success,
    Map<String, String>? params,
  });
}
