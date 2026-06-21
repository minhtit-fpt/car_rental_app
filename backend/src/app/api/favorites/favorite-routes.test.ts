import { beforeEach, describe, expect, it, vi } from "vitest";
import { KycStatus, UserRole } from "@prisma/client";

vi.mock("@/lib/middleware/rate-limit.middleware", () => ({
  enforceRateLimit: vi.fn(),
}));
vi.mock("@/lib/middleware/auth.middleware", () => ({ requireAuth: vi.fn() }));
vi.mock("@/lib/services/favorite.service", () => ({
  favoriteService: {
    list: vi.fn(),
    add: vi.fn(),
    remove: vi.fn(),
  },
}));

import { GET as listGET } from "@/app/api/favorites/route";
import {
  POST as addPOST,
  DELETE as removeDELETE,
} from "@/app/api/favorites/[vehicleId]/route";
import { favoriteService } from "@/lib/services/favorite.service";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { AppError } from "@/lib/errors/app-error";
import type { AccessTokenClaims } from "@/lib/auth/jwt";

const VEHICLE_ID = "11111111-1111-1111-1111-111111111111";

function req(method: string): Request {
  return new Request(`http://localhost/api/favorites/${VEHICLE_ID}`, {
    method,
  });
}

function claims(): AccessTokenClaims {
  return { sub: "user-1", roles: [UserRole.RENTER], kycStatus: KycStatus.VERIFIED };
}

beforeEach(() => vi.clearAllMocks());

describe("GET /api/favorites", () => {
  it("returns 200 with the saved vehicles", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims());
    vi.mocked(favoriteService.list).mockResolvedValue([]);

    const res = await listGET(
      new Request("http://localhost/api/favorites", { method: "GET" }),
    );

    expect(res.status).toBe(200);
    expect((await res.json()).success).toBe(true);
    expect(favoriteService.list).toHaveBeenCalledWith("user-1");
  });

  it("returns 401 when unauthenticated", async () => {
    vi.mocked(requireAuth).mockRejectedValue(
      new AppError(401, "UNAUTHORIZED", "Thiếu access token"),
    );

    const res = await listGET(
      new Request("http://localhost/api/favorites", { method: "GET" }),
    );

    expect(res.status).toBe(401);
    expect(favoriteService.list).not.toHaveBeenCalled();
  });
});

describe("POST /api/favorites/[vehicleId]", () => {
  it("returns 200 and reports favorited true", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims());
    vi.mocked(favoriteService.add).mockResolvedValue({
      vehicleId: VEHICLE_ID,
      favorited: true,
    });

    const res = await addPOST(req("POST"), { params: { vehicleId: VEHICLE_ID } });

    expect(res.status).toBe(200);
    expect((await res.json()).data.favorited).toBe(true);
    expect(favoriteService.add).toHaveBeenCalledWith("user-1", VEHICLE_ID);
  });

  it("returns 401 when unauthenticated", async () => {
    vi.mocked(requireAuth).mockRejectedValue(
      new AppError(401, "UNAUTHORIZED", "Thiếu access token"),
    );

    const res = await addPOST(req("POST"), { params: { vehicleId: VEHICLE_ID } });

    expect(res.status).toBe(401);
    expect(favoriteService.add).not.toHaveBeenCalled();
  });

  it("returns 400 when vehicleId is not a valid uuid", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims());

    const res = await addPOST(req("POST"), { params: { vehicleId: "not-uuid" } });

    expect(res.status).toBe(400);
    expect((await res.json()).code).toBe("VALIDATION_ERROR");
    expect(favoriteService.add).not.toHaveBeenCalled();
  });
});

describe("DELETE /api/favorites/[vehicleId]", () => {
  it("returns 200 and reports favorited false", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims());
    vi.mocked(favoriteService.remove).mockResolvedValue({
      vehicleId: VEHICLE_ID,
      favorited: false,
    });

    const res = await removeDELETE(req("DELETE"), {
      params: { vehicleId: VEHICLE_ID },
    });

    expect(res.status).toBe(200);
    expect((await res.json()).data.favorited).toBe(false);
    expect(favoriteService.remove).toHaveBeenCalledWith("user-1", VEHICLE_ID);
  });
});
