import { describe, expect, it } from "vitest";
import { createVnpayProvider } from "@/lib/payments/vnpay.provider";

const config = {
  tmnCode: "TESTTMN",
  hashSecret: "secret-key-123",
  payUrl: "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html",
  returnUrl: "https://ridevn.app/payment/return",
};

const provider = createVnpayProvider(config);

// Bóc query params từ payUrl trả về.
function parseQuery(url: string): Record<string, string> {
  const query = url.slice(url.indexOf("?") + 1);
  const out: Record<string, string> = {};
  for (const pair of query.split("&")) {
    const [k, v] = pair.split("=");
    out[k] = decodeURIComponent((v ?? "").replace(/\+/g, " "));
  }
  return out;
}

describe("vnpayProvider.createPayment", () => {
  it("builds a signed pay URL with VNPay params", async () => {
    const { payUrl, gatewayRef } = await provider.createPayment({
      reference: "pay-1",
      amount: 400,
      orderInfo: "Thanh toan don book-1",
    });

    expect(payUrl.startsWith(config.payUrl)).toBe(true);
    const params = parseQuery(payUrl);
    expect(params.vnp_TmnCode).toBe("TESTTMN");
    expect(params.vnp_TxnRef).toBe("pay-1");
    expect(params.vnp_Amount).toBe("40000"); // 400 * 100
    expect(params.vnp_SecureHash).toMatch(/^[0-9a-f]{128}$/);
    expect(gatewayRef).toBe("pay-1");
  });
});

describe("vnpayProvider.verifyCallback", () => {
  // Tạo bộ params return hợp lệ bằng cách ký lại với cùng secret qua createPayment
  // không khả thi (thiếu mã kết quả) — nên dựng params return thủ công rồi ký.
  async function signedReturnParams(
    overrides: Record<string, string> = {},
  ): Promise<Record<string, string>> {
    const { createHmac } = await import("node:crypto");
    const base: Record<string, string> = {
      vnp_Amount: "40000",
      vnp_BankCode: "NCB",
      vnp_ResponseCode: "00",
      vnp_TmnCode: "TESTTMN",
      vnp_TransactionNo: "14123456",
      vnp_TransactionStatus: "00",
      vnp_TxnRef: "pay-1",
      ...overrides,
    };
    const signData = Object.keys(base)
      .sort()
      .map(
        (k) =>
          `${encodeURIComponent(k)}=${encodeURIComponent(base[k]).replace(/%20/g, "+")}`,
      )
      .join("&");
    const hash = createHmac("sha512", config.hashSecret)
      .update(Buffer.from(signData, "utf-8"))
      .digest("hex");
    return { ...base, vnp_SecureHash: hash };
  }

  it("accepts a valid signature with success codes", async () => {
    const params = await signedReturnParams();
    expect(
      await provider.verifyCallback({
        reference: "pay-1",
        gatewayRef: "pay-1",
        success: true,
        params,
      }),
    ).toBe(true);
  });

  it("rejects a tampered signature", async () => {
    const params = await signedReturnParams();
    params.vnp_Amount = "1"; // đổi sau khi đã ký
    expect(
      await provider.verifyCallback({
        reference: "pay-1",
        gatewayRef: "pay-1",
        success: true,
        params,
      }),
    ).toBe(false);
  });

  it("rejects a declined transaction even with valid signature", async () => {
    const params = await signedReturnParams({
      vnp_ResponseCode: "24",
      vnp_TransactionStatus: "02",
    });
    expect(
      await provider.verifyCallback({
        reference: "pay-1",
        gatewayRef: "pay-1",
        success: true,
        params,
      }),
    ).toBe(false);
  });

  it("rejects when params are missing", async () => {
    expect(
      await provider.verifyCallback({
        reference: "pay-1",
        gatewayRef: "pay-1",
        success: true,
      }),
    ).toBe(false);
  });
});
