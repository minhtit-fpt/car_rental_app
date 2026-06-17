import 'package:frontend/features/payment/domain/entities/payment.dart';

sealed class PaymentState {
  const PaymentState();
}

/// Chưa bắt đầu — màn hiển thị nút "Thanh toán".
final class PaymentIdle extends PaymentState {
  const PaymentIdle();
}

/// Đang tạo phiên / chờ cổng xác nhận.
final class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

/// Cần mở WebView cổng VNPay thật. Màn hình mở [payUrl] và bắt URL return,
/// rồi gọi lại cubit để xác nhận với [paymentId].
final class PaymentAwaitingGateway extends PaymentState {
  const PaymentAwaitingGateway({required this.paymentId, required this.payUrl});
  final String paymentId;
  final String payUrl;
}

/// Thanh toán thành công (giao dịch PAID, đơn đã xác nhận).
final class PaymentSuccess extends PaymentState {
  const PaymentSuccess(this.payment);
  final Payment payment;
}

/// Thất bại — cổng từ chối hoặc lỗi mạng/nghiệp vụ.
final class PaymentFailure extends PaymentState {
  const PaymentFailure(this.message);
  final String message;
}
