import { beforeEach, describe, expect, it, vi } from "vitest";
import { BookingStatus, KycStatus, UserRole } from "@prisma/client";

vi.mock("@/lib/middleware/rate-limit.middleware", () => ({
  enforceRateLimit: vi.fn(),
}));
vi.mock("@/lib/middleware/auth.middleware", () => ({ requireAuth: vi.fn() }));
vi.mock("@/lib/services/booking.service", () => ({
  bookingService: {
    create: vi.fn(),
    list: vi.fn(),
    getById: vi.fn(),
    cancel: vi.fn(),
  },
}));

import { POST as createPOST, GET as listGET } from "@/app/api/bookings/route";
import { POST as cancelPOST } from "@/app/api/bookings/[id]/cancel/route";
import { bookingService } from "@/lib/services/booking.service";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { AppError } from "@/lib/errors/app-error";
import type { AccessTokenClaims } from "@/lib/auth/jwt";

function jsonReq(method: string, body: unknown, url = "/api/bookings"): Request {
  return new Request(`http://localhost${url}`, {
    method,
    headers: { "content-type": "application/json" },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
}

function claims(kycStatus: KycStatus): AccessTokenClaims {
  return { sub: "renter-1", roles: [UserRole.RENTER], kycStatus };
}

const VALID_BODY = {
  vehicleId: "11111111-1111-1111-1111-111111111111",
  startTime: "2026-07-01T08:00:00Z",
  endTime: "2026-07-01T12:00:00Z",
};

beforeEach(() => vi.clearAllMocks());

describe("POST /api/bookings", () => {
  it("returns 201 when the renter is KYC-verified", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims(KycStatus.VERIFIED));
    vi.mocked(bookingService.create).mockResolvedValue({
      status: BookingStatus.PENDING_PAYMENT,
    } as never);
    const res = await createPOST(jsonReq("POST", VALID_BODY));
    expect(res.status).toBe(201);
  });

  it("returns 403 KYC_REQUIRED when not verified", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims(KycStatus.UNVERIFIED));
    const res = await createPOST(jsonReq("POST", VALID_BODY));
    expect(res.status).toBe(403);
    expect((await res.json()).code).toBe("KYC_REQUIRED");
    expect(bookingService.create).not.toHaveBeenCalled();
  });

  it("returns 409 when the service reports a conflict", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims(KycStatus.VERIFIED));
    vi.mocked(bookingService.create).mockRejectedValue(
      new AppError(409, "BOOKING_CONFLICT", "Trùng giờ"),
    );
    const res = await createPOST(jsonReq("POST", VALID_BODY));
    expect(res.status).toBe(409);
    expect((await res.json()).code).toBe("BOOKING_CONFLICT");
  });

  it("returns 401 when unauthenticated", async () => {
    vi.mocked(requireAuth).mockRejectedValue(
      new AppError(401, "UNAUTHORIZED", "Thiếu access token"),
    );
    const res = await createPOST(jsonReq("POST", VALID_BODY));
    expect(res.status).toBe(401);
  });
});

describe("GET /api/bookings", () => {
  it("returns 200 with the renter's bookings", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims(KycStatus.VERIFIED));
    vi.mocked(bookingService.list).mockResolvedValue({
      items: [],
      total: 0,
      page: 1,
      limit: 20,
    });
    const res = await listGET(jsonReq("GET", undefined));
    expect(res.status).toBe(200);
    expect((await res.json()).data.page).toBe(1);
  });
});

describe("POST /api/bookings/[id]/cancel", () => {
  it("returns 200 on a successful cancel", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims(KycStatus.VERIFIED));
    vi.mocked(bookingService.cancel).mockResolvedValue({
      status: BookingStatus.CANCELLED,
    } as never);
    const res = await cancelPOST(jsonReq("POST", undefined), {
      params: { id: "book-1" },
    });
    expect(res.status).toBe(200);
    expect(bookingService.cancel).toHaveBeenCalledWith("renter-1", "book-1");
  });

  it("returns 409 when the booking cannot be cancelled", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims(KycStatus.VERIFIED));
    vi.mocked(bookingService.cancel).mockRejectedValue(
      new AppError(409, "BOOKING_NOT_CANCELLABLE", "Không thể huỷ"),
    );
    const res = await cancelPOST(jsonReq("POST", undefined), {
      params: { id: "book-1" },
    });
    expect(res.status).toBe(409);
  });
});
