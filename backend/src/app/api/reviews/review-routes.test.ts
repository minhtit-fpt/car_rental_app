import { beforeEach, describe, expect, it, vi } from "vitest";
import { KycStatus, UserRole } from "@prisma/client";

vi.mock("@/lib/middleware/rate-limit.middleware", () => ({
  enforceRateLimit: vi.fn(),
}));
vi.mock("@/lib/middleware/auth.middleware", () => ({ requireAuth: vi.fn() }));
vi.mock("@/lib/services/review.service", () => ({
  reviewService: { create: vi.fn(), listForTarget: vi.fn() },
}));
vi.mock("@/lib/services/user.service", () => ({
  userService: { updateProfile: vi.fn() },
}));

import { POST as createPOST } from "@/app/api/reviews/route";
import { GET as listGET } from "@/app/api/users/[id]/reviews/route";
import { PATCH as profilePATCH } from "@/app/api/users/me/route";
import { reviewService } from "@/lib/services/review.service";
import { userService } from "@/lib/services/user.service";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { AppError } from "@/lib/errors/app-error";
import type { AccessTokenClaims } from "@/lib/auth/jwt";

function jsonReq(method: string, body: unknown, url = "/api/reviews"): Request {
  return new Request(`http://localhost${url}`, {
    method,
    headers: { "content-type": "application/json" },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
}

const CLAIMS: AccessTokenClaims = {
  sub: "renter-1",
  roles: [UserRole.RENTER],
  kycStatus: KycStatus.VERIFIED,
};

const BOOKING_ID = "11111111-1111-1111-1111-111111111111";

beforeEach(() => vi.clearAllMocks());

describe("POST /api/reviews", () => {
  it("returns 201 on a valid review", async () => {
    vi.mocked(requireAuth).mockResolvedValue(CLAIMS);
    vi.mocked(reviewService.create).mockResolvedValue({ id: "rev-1" } as never);
    const res = await createPOST(
      jsonReq("POST", { bookingId: BOOKING_ID, rating: 5 }),
    );
    expect(res.status).toBe(201);
  });

  it("returns 409 when already reviewed", async () => {
    vi.mocked(requireAuth).mockResolvedValue(CLAIMS);
    vi.mocked(reviewService.create).mockRejectedValue(
      new AppError(409, "ALREADY_REVIEWED", "Đã đánh giá"),
    );
    const res = await createPOST(
      jsonReq("POST", { bookingId: BOOKING_ID, rating: 5 }),
    );
    expect(res.status).toBe(409);
    expect((await res.json()).code).toBe("ALREADY_REVIEWED");
  });

  it("returns 400 on an invalid rating", async () => {
    vi.mocked(requireAuth).mockResolvedValue(CLAIMS);
    const res = await createPOST(
      jsonReq("POST", { bookingId: BOOKING_ID, rating: 9 }),
    );
    expect(res.status).toBe(400);
    expect(reviewService.create).not.toHaveBeenCalled();
  });
});

describe("GET /api/users/[id]/reviews", () => {
  it("returns 200 with the review list", async () => {
    vi.mocked(requireAuth).mockResolvedValue(CLAIMS);
    vi.mocked(reviewService.listForTarget).mockResolvedValue({
      items: [],
      total: 0,
      average: 0,
      page: 1,
      limit: 20,
    });
    const res = await listGET(jsonReq("GET", undefined, "/api/users/owner-1/reviews"), {
      params: { id: "owner-1" },
    });
    expect(res.status).toBe(200);
    expect(reviewService.listForTarget).toHaveBeenCalledWith(
      "owner-1",
      expect.objectContaining({ page: 1 }),
    );
  });
});

describe("PATCH /api/users/me", () => {
  it("returns 200 and the updated profile", async () => {
    vi.mocked(requireAuth).mockResolvedValue(CLAIMS);
    vi.mocked(userService.updateProfile).mockResolvedValue({
      id: "renter-1",
      email: "new@example.com",
    } as never);
    const res = await profilePATCH(
      jsonReq("PATCH", { email: "new@example.com" }, "/api/users/me"),
    );
    expect(res.status).toBe(200);
    expect(userService.updateProfile).toHaveBeenCalledWith("renter-1", {
      email: "new@example.com",
    });
  });

  it("returns 409 when the email is taken", async () => {
    vi.mocked(requireAuth).mockResolvedValue(CLAIMS);
    vi.mocked(userService.updateProfile).mockRejectedValue(
      new AppError(409, "EMAIL_TAKEN", "Email đã dùng"),
    );
    const res = await profilePATCH(
      jsonReq("PATCH", { email: "taken@example.com" }, "/api/users/me"),
    );
    expect(res.status).toBe(409);
  });
});
