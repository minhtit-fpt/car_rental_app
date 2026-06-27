import type { PaymentProvider } from "@/lib/payments/payment.port";
import { mockVnpayProvider } from "@/lib/payments/vnpay.mock.provider";
import { vnpayProvider } from "@/lib/payments/vnpay.provider";

// Chọn adapter theo env: có đủ credentials VNPay thật → dùng adapter thật;
// thiếu → fallback mock (sandbox, không cần credentials) cho dev/test.
const hasVnpayCredentials = Boolean(
  process.env.VNPAY_TMN_CODE && process.env.VNPAY_HASH_SECRET,
);

export const paymentProvider: PaymentProvider = hasVnpayCredentials
  ? vnpayProvider
  : mockVnpayProvider;

/** Tên cổng đang hoạt động — client dùng để quyết định mở WebView (vnpay) hay
 *  tự xác nhận (mock). */
export const paymentProviderName: "vnpay" | "mock" = hasVnpayCredentials
  ? "vnpay"
  : "mock";

export type {
  CreatePaymentRequest,
  CreatePaymentResult,
  PaymentCallback,
  PaymentProvider,
} from "@/lib/payments/payment.port";
