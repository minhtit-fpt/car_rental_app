import { createHmac, timingSafeEqual } from "node:crypto";
import type {
  CreatePaymentRequest,
  CreatePaymentResult,
  PaymentCallback,
  PaymentProvider,
} from "@/lib/payments/payment.port";

// Adapter VNPay THẬT — ký HMAC-SHA512 theo vnp_HashSecret và xác thực
// vnp_SecureHash trên callback (return/IPN). Tài liệu: VNPay pay v2.1.0.

export interface VnpayConfig {
  tmnCode: string;
  hashSecret: string;
  /** Endpoint thanh toán (vpcpay.html sandbox hoặc live). */
  payUrl: string;
  /** URL VNPay redirect về sau khi thanh toán; WebView app bắt URL này. */
  returnUrl: string;
  /** IP người dùng — VNPay yêu cầu, chấp nhận giá trị mặc định. */
  ipAddr?: string;
}

const VND_MULTIPLIER = 100; // VNPay tính theo đơn vị nhỏ nhất.
const EXPIRE_MINUTES = 15;

// Định dạng yyyyMMddHHmmss theo giờ Việt Nam (GMT+7) không phụ thuộc TZ máy chủ.
function formatVnpDate(date: Date): string {
  const vn = new Date(date.getTime() + 7 * 60 * 60 * 1000);
  const pad = (n: number): string => String(n).padStart(2, "0");
  return (
    `${vn.getUTCFullYear()}${pad(vn.getUTCMonth() + 1)}${pad(vn.getUTCDate())}` +
    `${pad(vn.getUTCHours())}${pad(vn.getUTCMinutes())}${pad(vn.getUTCSeconds())}`
  );
}

// Chuỗi ký theo đúng thuật toán VNPay: sort khoá tăng dần, encode value và
// thay %20 bằng '+'. Dùng chung cho cả khi ký lẫn khi tạo URL cuối.
function buildSignData(params: Record<string, string>): string {
  return Object.keys(params)
    .sort()
    .map(
      (key) =>
        `${encodeURIComponent(key)}=${encodeURIComponent(params[key]).replace(/%20/g, "+")}`,
    )
    .join("&");
}

function hmacSha512(data: string, secret: string): string {
  return createHmac("sha512", secret)
    .update(Buffer.from(data, "utf-8"))
    .digest("hex");
}

// So sánh hex an toàn theo thời gian; tránh rò rỉ qua thời gian so chuỗi.
function safeHexEqual(a: string, b: string): boolean {
  const bufA = Buffer.from(a, "hex");
  const bufB = Buffer.from(b, "hex");
  return bufA.length === bufB.length && timingSafeEqual(bufA, bufB);
}

export function createVnpayProvider(config: VnpayConfig): PaymentProvider {
  const ipAddr = config.ipAddr ?? "127.0.0.1";

  return {
    async createPayment(
      req: CreatePaymentRequest,
    ): Promise<CreatePaymentResult> {
      const now = new Date();
      const params: Record<string, string> = {
        vnp_Version: "2.1.0",
        vnp_Command: "pay",
        vnp_TmnCode: config.tmnCode,
        vnp_Locale: "vn",
        vnp_CurrCode: "VND",
        vnp_TxnRef: req.reference,
        vnp_OrderInfo: req.orderInfo,
        vnp_OrderType: "other",
        vnp_Amount: String(Math.round(req.amount) * VND_MULTIPLIER),
        vnp_ReturnUrl: config.returnUrl,
        vnp_IpAddr: ipAddr,
        vnp_CreateDate: formatVnpDate(now),
        vnp_ExpireDate: formatVnpDate(
          new Date(now.getTime() + EXPIRE_MINUTES * 60 * 1000),
        ),
      };

      const signData = buildSignData(params);
      const secureHash = hmacSha512(signData, config.hashSecret);
      const payUrl = `${config.payUrl}?${signData}&vnp_SecureHash=${secureHash}`;

      // VNPay chưa cấp mã giao dịch lúc tạo; dùng TxnRef làm tham chiếu, sẽ cập
      // nhật vnp_TransactionNo khi callback nếu cần.
      return { payUrl, gatewayRef: req.reference };
    },

    async verifyCallback(callback: PaymentCallback): Promise<boolean> {
      const params = callback.params;
      const received = params?.vnp_SecureHash;
      if (!params || !received) return false;

      const rest: Record<string, string> = { ...params };
      delete rest.vnp_SecureHash;
      delete rest.vnp_SecureHashType;

      const expected = hmacSha512(buildSignData(rest), config.hashSecret);
      if (!safeHexEqual(expected, received)) return false;

      // Hợp lệ về chữ ký → kiểm tra mã kết quả giao dịch.
      return (
        params.vnp_ResponseCode === "00" &&
        params.vnp_TransactionStatus === "00"
      );
    },
  };
}

// Instance mặc định đọc từ env (chỉ dùng khi đủ credentials — xem index.ts).
export const vnpayProvider: PaymentProvider = createVnpayProvider({
  tmnCode: process.env.VNPAY_TMN_CODE ?? "",
  hashSecret: process.env.VNPAY_HASH_SECRET ?? "",
  payUrl:
    process.env.VNPAY_SANDBOX_URL ??
    "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html",
  returnUrl: process.env.VNPAY_RETURN_URL ?? "https://ridevn.app/payment/return",
});
