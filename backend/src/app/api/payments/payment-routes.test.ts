import { beforeEach, describe, expect, it, vi } from "vitest";
import { KycStatus, PaymentStatus, UserRole } from "@prisma/client";

vi.mock("@/lib/middleware/rate-limit.middleware", () => ({
  enforceRateLimit: vi.fn(),
}));
vi.mock("@/lib/middleware/auth.middleware", () => ({ requireAuth: vi.fn() }));
vi.mock("@/lib/services/payment.service", () => ({
  paymentService: {
    create: vi.fn(),
    getById: vi.fn(),
    confirm: vi.fn(),
  },
}));

import { POST as createPOST } from "@/app/api/payments/route";
import { POST as confirmPOST } from "@/app/api/payments/[id]/confirm/route";
import { paymentService } from "@/lib/services/payment.service";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { AppError } from "@/lib/errors/app-error";
import type { AccessTokenClaims } from "@/lib/auth/jwt";

function jsonReq(method: string, body: unknown, url = "/api/payments"): Request {
  return new Request(`http://localhost${url}`, {
    method,
    headers: { "content-type": "application/json" },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
}

function claims(kycStatus: KycStatus): AccessTokenClaims {
  return { sub: "renter-1", roles: [UserRole.RENTER], kycStatus };
}

const BOOKING_ID = "11111111-1111-1111-1111-111111111111";

beforeEach(() => vi.clearAllMocks());

describe("POST /api/payments", () => {
  it("returns 201 with payUrl when KYC-verified", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims(KycStatus.VERIFIED));
    vi.mocked(paymentService.create).mockResolvedValue({
      payment: { status: PaymentStatus.PENDING },
      payUrl: "https://sandbox/pay",
    } as never);
    const res = await createPOST(jsonReq("POST", { bookingId: BOOKING_ID }));
    expect(res.status).toBe(201);
    expect((await res.json()).data.payUrl).toBe("https://sandbox/pay");
  });

  it("returns 403 KYC_REQUIRED when not verified", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims(KycStatus.UNVERIFIED));
    const res = await createPOST(jsonReq("POST", { bookingId: BOOKING_ID }));
    expect(res.status).toBe(403);
    expect((await res.json()).code).toBe("KYC_REQUIRED");
    expect(paymentService.create).not.toHaveBeenCalled();
  });

  it("returns 409 when the service reports already paid", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims(KycStatus.VERIFIED));
    vi.mocked(paymentService.create).mockRejectedValue(
      new AppError(409, "ALREADY_PAID", "Đã thanh toán"),
    );
    const res = await createPOST(jsonReq("POST", { bookingId: BOOKING_ID }));
    expect(res.status).toBe(409);
    expect((await res.json()).code).toBe("ALREADY_PAID");
  });
});

describe("POST /api/payments/[id]/confirm", () => {
  it("returns 200 and confirms on a successful callback", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims(KycStatus.VERIFIED));
    vi.mocked(paymentService.confirm).mockResolvedValue({
      payment: { status: PaymentStatus.PAID },
      booking: { status: "CONFIRMED" },
    } as never);
    const res = await confirmPOST(jsonReq("POST", { success: true }), {
      params: { id: "pay-1" },
    });
    expect(res.status).toBe(200);
    expect(paymentService.confirm).toHaveBeenCalledWith("renter-1", "pay-1", {
      success: true,
    });
  });

  it("returns 409 when confirming hits a booking conflict", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims(KycStatus.VERIFIED));
    vi.mocked(paymentService.confirm).mockRejectedValue(
      new AppError(409, "BOOKING_CONFLICT", "Trùng giờ"),
    );
    const res = await confirmPOST(jsonReq("POST", { success: true }), {
      params: { id: "pay-1" },
    });
    expect(res.status).toBe(409);
    expect((await res.json()).code).toBe("BOOKING_CONFLICT");
  });
});
