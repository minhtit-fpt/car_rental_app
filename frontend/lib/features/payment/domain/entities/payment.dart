/// Phương thức thanh toán — khớp enum `PaymentMethod` của backend.
enum PaymentMethod {
  vnpay,
  momo,
  stripe,
  cash,
  unknown;

  static PaymentMethod fromApi(String? raw) => switch (raw) {
    'VNPAY' => PaymentMethod.vnpay,
    'MOMO' => PaymentMethod.momo,
    'STRIPE' => PaymentMethod.stripe,
    'CASH' => PaymentMethod.cash,
    _ => PaymentMethod.unknown,
  };
}

/// Trạng thái giao dịch — khớp enum `PaymentStatus` của backend.
enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
  unknown;

  static PaymentStatus fromApi(String? raw) => switch (raw) {
    'PENDING' => PaymentStatus.pending,
    'PAID' => PaymentStatus.paid,
    'FAILED' => PaymentStatus.failed,
    'REFUNDED' => PaymentStatus.refunded,
    _ => PaymentStatus.unknown,
  };

  bool get isPaid => this == PaymentStatus.paid;
}

/// Giao dịch thanh toán — phản chiếu `PublicPayment` của backend.
class Payment {
  const Payment({
    required this.id,
    required this.bookingId,
    required this.method,
    required this.status,
    required this.amount,
    required this.createdAt,
    this.gatewayRef,
    this.paidAt,
  });

  final String id;
  final String bookingId;
  final PaymentMethod method;
  final PaymentStatus status;
  final double amount;
  final DateTime createdAt;
  final String? gatewayRef;
  final DateTime? paidAt;
}

/// Kết quả tạo phiên thanh toán: giao dịch + URL cổng (`POST /api/payments`).
class PaymentSession {
  const PaymentSession({
    required this.payment,
    required this.payUrl,
    required this.provider,
  });

  final Payment payment;
  final String payUrl;

  /// Cổng đang hoạt động: `'vnpay'` → mở WebView; `'mock'` → tự xác nhận.
  final String provider;

  bool get isMockGateway => provider == 'mock';
}
