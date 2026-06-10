import { beforeEach, describe, expect, it, vi } from "vitest";
import { KycStatus, UserRole } from "@prisma/client";

vi.mock("@/lib/middleware/rate-limit.middleware", () => ({
  enforceRateLimit: vi.fn(),
}));
vi.mock("@/lib/middleware/auth.middleware", () => ({ requireAuth: vi.fn() }));
vi.mock("@/lib/services/kyc.service", () => ({
  kycService: {
    createUploadUrl: vi.fn(),
    submit: vi.fn(),
    getStatus: vi.fn(),
    review: vi.fn(),
    getReviewDocuments: vi.fn(),
  },
}));

import { POST as uploadUrlPOST } from "@/app/api/kyc/upload-url/route";
import { POST as submitPOST } from "@/app/api/kyc/submit/route";
import { GET as statusGET } from "@/app/api/kyc/status/route";
import { POST as reviewPOST } from "@/app/api/kyc/[id]/review/route";
import { GET as documentsGET } from "@/app/api/kyc/[id]/documents/route";
import { kycService } from "@/lib/services/kyc.service";
import { requireAuth } from "@/lib/middleware/auth.middleware";
import { AppError } from "@/lib/errors/app-error";
import type { AccessTokenClaims } from "@/lib/auth/jwt";

function postReq(body: unknown, raw?: string): Request {
  return new Request("http://localhost/api/kyc", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: raw ?? JSON.stringify(body),
  });
}

function getReq(): Request {
  return new Request("http://localhost/api/kyc/status", { method: "GET" });
}

function claims(roles: UserRole[] = [UserRole.RENTER]): AccessTokenClaims {
  return { sub: "user-1", roles, kycStatus: KycStatus.UNVERIFIED };
}

const OWNED_KEYS = {
  cccdKey: "kyc/user-1/cccd-1",
  licenseKey: "kyc/user-1/license-1",
  faceKey: "kyc/user-1/face-1",
};

beforeEach(() => vi.clearAllMocks());

describe("POST /api/kyc/upload-url", () => {
  it("returns 200 with a presigned upload URL", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims());
    vi.mocked(kycService.createUploadUrl).mockResolvedValue({
      uploadUrl: "https://minio.local/put",
      objectKey: "kyc/user-1/cccd-1.jpg",
    });
    const res = await uploadUrlPOST(
      postReq({ docType: "cccd", contentType: "image/jpeg" }),
    );
    expect(res.status).toBe(200);
    expect((await res.json()).data.uploadUrl).toBe("https://minio.local/put");
  });

  it("returns 400 on an invalid content-type", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims());
    const res = await uploadUrlPOST(
      postReq({ docType: "cccd", contentType: "application/pdf" }),
    );
    expect(res.status).toBe(400);
  });
});

describe("GET /api/kyc/[id]/documents", () => {
  const ctx = { params: { id: "kyc-1" } };

  it("returns 200 with presigned document URLs for an ADMIN", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.ADMIN]));
    vi.mocked(kycService.getReviewDocuments).mockResolvedValue({
      cccdUrl: "https://minio.local/get/cccd",
      licenseUrl: "https://minio.local/get/license",
      faceUrl: "https://minio.local/get/face",
    });
    const res = await documentsGET(getReq(), ctx);
    expect(res.status).toBe(200);
    expect((await res.json()).data.cccdUrl).toContain("cccd");
  });

  it("returns 403 for a non-ADMIN", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.RENTER]));
    const res = await documentsGET(getReq(), ctx);
    expect(res.status).toBe(403);
    expect(kycService.getReviewDocuments).not.toHaveBeenCalled();
  });
});

describe("POST /api/kyc/submit", () => {
  it("returns 201 on a valid submission", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims());
    vi.mocked(kycService.submit).mockResolvedValue({
      status: KycStatus.PENDING,
    } as never);

    const res = await submitPOST(postReq(OWNED_KEYS));
    expect(res.status).toBe(201);
    expect((await res.json()).success).toBe(true);
  });

  it("returns 401 when unauthenticated", async () => {
    vi.mocked(requireAuth).mockRejectedValue(
      new AppError(401, "UNAUTHORIZED", "Thiếu access token"),
    );
    const res = await submitPOST(postReq(OWNED_KEYS));
    expect(res.status).toBe(401);
  });

  it("returns 400 VALIDATION_ERROR when a key is missing", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims());
    const res = await submitPOST(postReq({ cccdKey: "kyc/user-1/cccd-1" }));
    expect(res.status).toBe(400);
    expect((await res.json()).code).toBe("VALIDATION_ERROR");
  });
});

describe("GET /api/kyc/status", () => {
  it("returns 200 with the current status", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims());
    vi.mocked(kycService.getStatus).mockResolvedValue({
      status: KycStatus.PENDING,
      rejectReason: null,
      reviewedAt: null,
      submittedAt: new Date(),
    });
    const res = await statusGET(getReq());
    expect(res.status).toBe(200);
    expect((await res.json()).data.status).toBe(KycStatus.PENDING);
  });

  it("returns 401 when unauthenticated", async () => {
    vi.mocked(requireAuth).mockRejectedValue(
      new AppError(401, "UNAUTHORIZED", "Thiếu access token"),
    );
    const res = await statusGET(getReq());
    expect(res.status).toBe(401);
  });
});

describe("POST /api/kyc/[id]/review", () => {
  const ctx = { params: { id: "kyc-1" } };

  it("returns 200 when an ADMIN approves", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.ADMIN]));
    vi.mocked(kycService.review).mockResolvedValue({
      status: KycStatus.VERIFIED,
    } as never);
    const res = await reviewPOST(postReq({ decision: "approve" }), ctx);
    expect(res.status).toBe(200);
    expect(kycService.review).toHaveBeenCalledWith("user-1", "kyc-1", {
      decision: "approve",
    });
  });

  it("returns 403 when a non-ADMIN attempts review", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.RENTER]));
    const res = await reviewPOST(postReq({ decision: "approve" }), ctx);
    expect(res.status).toBe(403);
    expect((await res.json()).code).toBe("FORBIDDEN");
    expect(kycService.review).not.toHaveBeenCalled();
  });

  it("returns 404 when the service reports the record is missing", async () => {
    vi.mocked(requireAuth).mockResolvedValue(claims([UserRole.ADMIN]));
    vi.mocked(kycService.review).mockRejectedValue(
      new AppError(404, "KYC_NOT_FOUND", "Không tìm thấy hồ sơ KYC"),
    );
    const res = await reviewPOST(postReq({ decision: "approve" }), ctx);
    expect(res.status).toBe(404);
    expect((await res.json()).code).toBe("KYC_NOT_FOUND");
  });
});
