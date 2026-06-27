import { beforeEach, describe, expect, it, vi } from "vitest";
import { KycStatus, UserRole } from "@prisma/client";

vi.mock("@/lib/middleware/rate-limit.middleware", () => ({
  enforceRateLimit: vi.fn(),
}));
vi.mock("@/lib/middleware/auth.middleware", () => ({ requireAuth: vi.fn() }));
vi.mock("@/lib/services/vehicle.service", () => ({
  vehicleService: {
    list: vi.fn(),
    getById: vi.fn(),
    nearby: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    remove: vi.fn(),
  },
}));
vi.mock("@/lib/services/pricing.service", () => ({
  pricingService: { quoteForVehicle: vi.fn() },
}));

import { GET as listGET, POST as createPOST } from "@/app/api/vehicles/route";
import { GET as nearbyGET } from "@/app/api/vehicles/nearby/route";
import {
  GET as detailGET,
  PATCH as updatePATCH,
  DELETE as deleteDELETE,
} from "@/app/api/vehicles/[id]/route";
import { GET as priceQuoteGET } from "@/app/api/vehicles/[id]/price-quote/route";
import { vehicleService } from "@/lib/services/vehicle.service";
import { pricingService } from "@/lib/services/pricing.service";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { AppError } from "@/lib/errors/app-error";
import type { AccessTokenClaims } from "@/lib/auth/jwt";

function getReq(url: string): Request {
  return new Request(`http://localhost${url}`, { method: "GET" });
}

function bodyReq(method: string, body: unknown): Request {
  return new Request("http://localhost/api/vehicles", {
    method,
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
  });
}

function claims(roles: UserRole[]): AccessTokenClaims {
  return { sub: "user-1", roles, kycStatus: KycStatus.VERIFIED };
}

const VALID_CREATE = {
  type: "CAR",
  title: "Vinfast VF8",
  pricePerHour: 120,
  lat: 10.77,
  lng: 106.7,
};

beforeEach(() => vi.clearAllMocks());

describe("GET /api/vehicles", () => {
  it("returns 200 with a paginated list", async () => {
    vi.mocked(vehicleService.list).mockResolvedValue({
      items: [],
      total: 0,
      page: 1,
      limit: 20,
    });
    const res = await listGET(getReq("/api/vehicles?type=CAR"));
    expect(res.status).toBe(200);
    expect((await res.json()).data.page).toBe(1);
  });
});

describe("GET /api/vehicles/nearby", () => {
  it("returns 200 with nearby vehicles", async () => {
    vi.mocked(vehicleService.nearby).mockResolvedValue([]);
    const res = await nearbyGET(getReq("/api/vehicles/nearby?lat=10.7&lng=106.7"));
    expect(res.status).toBe(200);
  });

  it("returns 400 when lat/lng are missing", async () => {
    const res = await nearbyGET(getReq("/api/vehicles/nearby"));
    expect(res.status).toBe(400);
    expect((await res.json()).code).toBe("VALIDATION_ERROR");
  });
});

describe("GET /api/vehicles/[id]", () => {
  it("returns 404 when the service reports not found", async () => {
    vi.mocked(vehicleService.getById).mockRejectedValue(
      new AppError(404, "VEHICLE_NOT_FOUND", "Không tìm thấy xe"),
    );
    const res = await detailGET(getReq("/api/vehicles/x"), {
      params: { id: "x" },
    });
    expect(res.status).toBe(404);
  });
});

describe("GET /api/vehicles/[id]/price-quote", () => {
  const RANGE =
    "startTime=2026-07-01T08:00:00Z&endTime=2026-07-01T12:00:00Z";

  it("returns 200 with the explainable quote", async () => {
    vi.mocked(pricingService.quoteForVehicle).mockResolvedValue({
      basePricePerHour: 100,
      hours: 4,
      basePrice: 400,
      factors: [],
      finalPrice: 400,
      currency: "VND",
    });
    const res = await priceQuoteGET(
      getReq(`/api/vehicles/veh-1/price-quote?${RANGE}`),
      { params: { id: "veh-1" } },
    );
    expect(res.status).toBe(200);
    expect((await res.json()).data.finalPrice).toBe(400);
  });

  it("returns 400 when the time range is missing", async () => {
    const res = await priceQuoteGET(getReq("/api/vehicles/veh-1/price-quote"), {
      params: { id: "veh-1" },
    });
    expect(res.status).toBe(400);
    expect(pricingService.quoteForVehicle).not.toHaveBeenCalled();
  });

  it("returns 404 when the vehicle does not exist", async () => {
    vi.mocked(pricingService.quoteForVehicle).mockRejectedValue(
      new AppError(404, "VEHICLE_NOT_FOUND", "Không tìm thấy xe"),
    );
    const res = await priceQuoteGET(
      getReq(`/api/vehicles/nope/price-quote?${RANGE}`),
      { params: { id: "nope" } },
    );
    expect(res.status).toBe(404);
  });
});

describe("POST /api/vehicles", () => {
  it("returns 201 for an OWNER", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.OWNER]));
    vi.mocked(vehicleService.create).mockResolvedValue({ id: "veh-1" } as never);
    const res = await createPOST(bodyReq("POST", VALID_CREATE));
    expect(res.status).toBe(201);
  });

  it("returns 403 for a non-OWNER", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.RENTER]));
    const res = await createPOST(bodyReq("POST", VALID_CREATE));
    expect(res.status).toBe(403);
    expect(vehicleService.create).not.toHaveBeenCalled();
  });

  it("returns 401 when unauthenticated", async () => {
    vi.mocked(requireAuth).mockRejectedValue(
      new AppError(401, "UNAUTHORIZED", "Thiếu access token"),
    );
    const res = await createPOST(bodyReq("POST", VALID_CREATE));
    expect(res.status).toBe(401);
  });
});

describe("PATCH/DELETE /api/vehicles/[id]", () => {
  it("PATCH returns 403 when the service rejects a non-owner", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.OWNER]));
    vi.mocked(vehicleService.update).mockRejectedValue(
      new AppError(403, "FORBIDDEN", "Bạn không phải chủ xe này"),
    );
    const res = await updatePATCH(bodyReq("PATCH", { title: "New" }), {
      params: { id: "veh-1" },
    });
    expect(res.status).toBe(403);
  });

  it("DELETE returns 200 for the owner", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.OWNER]));
    vi.mocked(vehicleService.remove).mockResolvedValue();
    const res = await deleteDELETE(getReq("/api/vehicles/veh-1"), {
      params: { id: "veh-1" },
    });
    expect(res.status).toBe(200);
    expect((await res.json()).data.deleted).toBe(true);
  });
});
