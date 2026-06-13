import { randomUUID } from "node:crypto";
import type {
  CreatePaymentRequest,
  CreatePaymentResult,
  PaymentCallback,
  PaymentProvider,
} from "@/lib/payments/payment.port";

// Adapter VNPay GIẢ LẬP cho MVP — không gọi cổng thật, không cần credentials.
// Sinh payUrl sandbox xác định + gatewayRef, và tin tưởng cờ success ở callback.
// Adapter thật sẽ ký HMAC theo vnp_HashSecret và xác thực vnp_SecureHash.

const SANDBOX_BASE =
  process.env.VNPAY_SANDBOX_URL ?? "https://sandbox.vnpayment.vn/paymentv2/mock";

export const mockVnpayProvider: PaymentProvider = {
  async createPayment(req: CreatePaymentRequest): Promise<CreatePaymentResult> {
    const gatewayRef = `VNPAY-${randomUUID()}`;
    const params = new URLSearchParams({
      ref: req.reference,
      txn: gatewayRef,
      amount: String(Math.round(req.amount)),
      info: req.orderInfo,
    });
    return { payUrl: `${SANDBOX_BASE}?${params.toString()}`, gatewayRef };
  },

  async verifyCallback(callback: PaymentCallback): Promise<boolean> {
    // Mock: không có credentials để xác thực chữ ký → tin cờ success.
    return callback.success;
  },
};
