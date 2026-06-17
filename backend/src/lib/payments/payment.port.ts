// Cổng thanh toán trừu tượng — service chỉ phụ thuộc interface này, không phụ
// thuộc SDK/cổng cụ thể. Adapter thật (VNPay live) thay vào sau mà không đụng
// service. MVP dùng mock adapter (sandbox, không cần credentials thật).

export interface CreatePaymentRequest {
  /** Mã tham chiếu nội bộ (paymentId) để gắn vào callback từ cổng. */
  reference: string;
  /** Số tiền (VND). */
  amount: number;
  /** Mô tả đơn hiển thị ở cổng. */
  orderInfo: string;
}

export interface CreatePaymentResult {
  /** URL chuyển hướng người dùng sang cổng thanh toán. */
  payUrl: string;
  /** Mã giao dịch phía cổng, lưu vào Payment.gatewayRef. */
  gatewayRef: string;
}

export interface PaymentCallback {
  reference: string;
  gatewayRef: string;
  success: boolean;
  /** Chữ ký cổng gửi kèm; adapter thật xác thực, mock bỏ qua. */
  signature?: string;
  /** Toàn bộ tham số `vnp_*` thô từ return/IPN của VNPay. Adapter thật dùng để
   *  tính lại HMAC và đối chiếu `vnp_SecureHash`; mock bỏ qua. */
  params?: Record<string, string>;
}

export interface PaymentProvider {
  createPayment(req: CreatePaymentRequest): Promise<CreatePaymentResult>;
  /** Xác thực callback từ cổng. Trả về true nếu hợp lệ + thành công. */
  verifyCallback(callback: PaymentCallback): Promise<boolean>;
}
