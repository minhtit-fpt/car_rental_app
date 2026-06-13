import type { PaymentProvider } from "@/lib/payments/payment.port";
import { mockVnpayProvider } from "@/lib/payments/vnpay.mock.provider";

// Điểm chọn adapter. MVP: mock VNPay. Đổi sang adapter thật ở đây khi sẵn sàng.
export const paymentProvider: PaymentProvider = mockVnpayProvider;

export type {
  CreatePaymentRequest,
  CreatePaymentResult,
  PaymentCallback,
  PaymentProvider,
} from "@/lib/payments/payment.port";
