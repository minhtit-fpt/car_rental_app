import { beforeEach, describe, expect, it, vi } from "vitest";
import { KycStatus, UserRole } from "@prisma/client";

vi.mock("@/lib/middleware/rate-limit.middleware", () => ({
  enforceRateLimit: vi.fn(),
}));
vi.mock("@/lib/middleware/auth.middleware", () => ({ requireAuth: vi.fn() }));
vi.mock("@/lib/services/inspection.service", () => ({
  inspectionService: {
    createUploadUrl: vi.fn(),
    submit: vi.fn(),
    analyzeDamage: vi.fn(),
    getReport: vi.fn(),
  },
}));

import { POST as uploadUrlPOST } from "@/app/api/bookings/[id]/inspections/upload-url/route";
import { PUT as submitPUT } from "@/app/api/bookings/[id]/inspections/route";
import {
  POST as analyzePOST,
  GET as reportGET,
} from "@/app/api/bookings/[id]/damage-report/route";
import { inspectionService } from "@/lib/services/inspection.service";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { AppError } from "@/lib/errors/app-error";
import type { AccessTokenClaims } from "@/lib/auth/jwt";

function bodyReq(method: string, body: unknown): Request {
  return new Request("http://localhost/api/bookings/b-1/inspections", {
    method,
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
  });
}

function getReq(): Request {
  return new Request("http://localhost/api/bookings/b-1/damage-report", {
    method: "GET",
  });
}

function claims(roles: UserRole[]): AccessTokenClaims {
  return { sub: "user-1", roles, kycStatus: KycStatus.VERIFIED };
}

const ctx = { params: { id: "b-1" } };

beforeEach(() => vi.clearAllMocks());

describe("POST /api/bookings/[id]/inspections/upload-url", () => {
  it("returns 200 with a presigned upload URL", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.RENTER]));
    vi.mocked(inspectionService.createUploadUrl).mockResolvedValue({
      uploadUrl: "https://minio.local/put",
      objectKey: "inspections/b-1/checkin/x.jpg",
    });
    const res = await uploadUrlPOST(
      bodyReq("POST", { phase: "CHECKIN", contentType: "image/jpeg" }),
      ctx,
    );
    expect(res.status).toBe(200);
    expect((await res.json()).data.objectKey).toContain("inspections/b-1/");
  });

  it("returns 400 on an invalid contentType", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.RENTER]));
    const res = await uploadUrlPOST(
      bodyReq("POST", { phase: "CHECKIN", contentType: "image/gif" }),
      ctx,
    );
    expect(res.status).toBe(400);
    expect(inspectionService.createUploadUrl).not.toHaveBeenCalled();
  });

  it("returns 401 when unauthenticated", async () => {
    vi.mocked(requireAuth).mockRejectedValue(
      new AppError(401, "UNAUTHORIZED", "Thiếu access token"),
    );
    const res = await uploadUrlPOST(
      bodyReq("POST", { phase: "CHECKIN", contentType: "image/jpeg" }),
      ctx,
    );
    expect(res.status).toBe(401);
  });
});

describe("PUT /api/bookings/[id]/inspections", () => {
  it("returns 200 when photos are submitted", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.RENTER]));
    vi.mocked(inspectionService.submit).mockResolvedValue({
      phase: "CHECKOUT",
      photoCount: 2,
      findings: { summary: "Không phát hiện hư hỏng", damageCount: 0 },
    });
    const res = await submitPUT(
      bodyReq("PUT", {
        phase: "CHECKOUT",
        photoKeys: ["inspections/b-1/checkout/a.jpg"],
      }),
      ctx,
    );
    expect(res.status).toBe(200);
    expect((await res.json()).data.photoCount).toBe(2);
  });

  it("returns 400 when photoKeys is empty", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.RENTER]));
    const res = await submitPUT(
      bodyReq("PUT", { phase: "CHECKIN", photoKeys: [] }),
      ctx,
    );
    expect(res.status).toBe(400);
    expect(inspectionService.submit).not.toHaveBeenCalled();
  });

  it("returns 403 when the user is not a party of the booking", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.RENTER]));
    vi.mocked(inspectionService.submit).mockRejectedValue(
      new AppError(403, "FORBIDDEN", "Bạn không thuộc đơn đặt này"),
    );
    const res = await submitPUT(
      bodyReq("PUT", {
        phase: "CHECKIN",
        photoKeys: ["inspections/b-1/checkin/a.jpg"],
      }),
      ctx,
    );
    expect(res.status).toBe(403);
  });
});

describe("damage-report routes", () => {
  it("POST returns 200 with the analysis", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.RENTER]));
    vi.mocked(inspectionService.analyzeDamage).mockResolvedValue({
      summary: "1 vết trầy",
      items: [{ label: "trầy", severity: "minor", description: "" }],
      estimatedCost: 300000,
      createdAt: new Date(),
      beforePhotos: [],
      afterPhotos: [],
    });
    const res = await analyzePOST(getReq(), ctx);
    expect(res.status).toBe(200);
    expect((await res.json()).data.estimatedCost).toBe(300000);
  });

  it("POST returns 409 when inspections are incomplete", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.RENTER]));
    vi.mocked(inspectionService.analyzeDamage).mockRejectedValue(
      new AppError(409, "INSPECTION_INCOMPLETE", "Cần đủ ảnh"),
    );
    const res = await analyzePOST(getReq(), ctx);
    expect(res.status).toBe(409);
  });

  it("GET returns 404 when no report exists", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.RENTER]));
    vi.mocked(inspectionService.getReport).mockRejectedValue(
      new AppError(404, "DAMAGE_REPORT_NOT_FOUND", "Chưa có báo cáo"),
    );
    const res = await reportGET(getReq(), ctx);
    expect(res.status).toBe(404);
  });
});
