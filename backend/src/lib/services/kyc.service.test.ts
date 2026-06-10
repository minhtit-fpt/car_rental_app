import { beforeEach, describe, expect, it, vi } from "vitest";
import { KycStatus, type KYCVerification } from "@prisma/client";

vi.mock("@/lib/repositories/kyc.repository", () => ({
  kycRepository: {
    findByUserId: vi.fn(),
    findById: vi.fn(),
    upsertSubmission: vi.fn(),
    updateReview: vi.fn(),
  },
}));

vi.mock("@/lib/repositories/user.repository", () => ({
  userRepository: {
    updateKycStatus: vi.fn(),
  },
}));

vi.mock("@/lib/storage", () => ({
  storage: {
    presignUpload: vi.fn(async () => "https://minio.local/presigned-put"),
    presignDownload: vi.fn(async (key: string) => `https://minio.local/get/${key}`),
  },
}));

import { kycService } from "@/lib/services/kyc.service";
import { AppError } from "@/lib/errors/app-error";
import { kycRepository } from "@/lib/repositories/kyc.repository";
import { userRepository } from "@/lib/repositories/user.repository";
import { storage } from "@/lib/storage";

const USER_ID = "user-1";

function makeRecord(overrides: Partial<KYCVerification> = {}): KYCVerification {
  return {
    id: "kyc-1",
    userId: USER_ID,
    cccdUrl: `kyc/${USER_ID}/cccd-1`,
    licenseUrl: `kyc/${USER_ID}/license-1`,
    faceUrl: `kyc/${USER_ID}/face-1`,
    status: KycStatus.PENDING,
    reviewedBy: null,
    reviewedAt: null,
    rejectReason: null,
    createdAt: new Date("2026-06-10T00:00:00Z"),
    updatedAt: new Date("2026-06-10T00:00:00Z"),
    ...overrides,
  };
}

function ownedKeys() {
  return {
    cccdKey: `kyc/${USER_ID}/cccd-1`,
    licenseKey: `kyc/${USER_ID}/license-1`,
    faceKey: `kyc/${USER_ID}/face-1`,
  };
}

beforeEach(() => vi.clearAllMocks());

describe("kycService.createUploadUrl", () => {
  it("presigns an upload under the user's key prefix with the right extension", async () => {
    const result = await kycService.createUploadUrl(USER_ID, {
      docType: "cccd",
      contentType: "image/png",
    });

    expect(result.uploadUrl).toBe("https://minio.local/presigned-put");
    expect(result.objectKey).toMatch(
      new RegExp(`^kyc/${USER_ID}/cccd-[0-9a-f-]+\\.png$`),
    );
    expect(storage.presignUpload).toHaveBeenCalledWith(result.objectKey);
  });
});

describe("kycService.getReviewDocuments", () => {
  it("returns presigned GET URLs for all three documents", async () => {
    vi.mocked(kycRepository.findById).mockResolvedValue(makeRecord());
    const result = await kycService.getReviewDocuments("kyc-1");
    expect(result.cccdUrl).toContain(`kyc/${USER_ID}/cccd-1`);
    expect(result.licenseUrl).toContain(`kyc/${USER_ID}/license-1`);
    expect(result.faceUrl).toContain(`kyc/${USER_ID}/face-1`);
    expect(storage.presignDownload).toHaveBeenCalledTimes(3);
  });

  it("throws 404 when the record is missing", async () => {
    vi.mocked(kycRepository.findById).mockResolvedValue(null);
    await expect(kycService.getReviewDocuments("missing")).rejects.toBeInstanceOf(
      AppError,
    );
    expect(storage.presignDownload).not.toHaveBeenCalled();
  });
});

describe("kycService.submit", () => {
  it("stores the submission and moves the user to PENDING", async () => {
    vi.mocked(kycRepository.upsertSubmission).mockResolvedValue(makeRecord());

    const result = await kycService.submit(USER_ID, ownedKeys());

    expect(kycRepository.upsertSubmission).toHaveBeenCalledWith(USER_ID, {
      cccdUrl: `kyc/${USER_ID}/cccd-1`,
      licenseUrl: `kyc/${USER_ID}/license-1`,
      faceUrl: `kyc/${USER_ID}/face-1`,
    });
    expect(userRepository.updateKycStatus).toHaveBeenCalledWith(
      USER_ID,
      KycStatus.PENDING,
    );
    expect(result.status).toBe(KycStatus.PENDING);
  });

  it("rejects a key that belongs to another user (403)", async () => {
    await expect(
      kycService.submit(USER_ID, {
        ...ownedKeys(),
        faceKey: "kyc/attacker/face-9",
      }),
    ).rejects.toMatchObject({ status: 403, code: "FORBIDDEN" });
    expect(kycRepository.upsertSubmission).not.toHaveBeenCalled();
    expect(userRepository.updateKycStatus).not.toHaveBeenCalled();
  });
});

describe("kycService.getStatus", () => {
  it("returns UNVERIFIED when no record exists", async () => {
    vi.mocked(kycRepository.findByUserId).mockResolvedValue(null);
    const result = await kycService.getStatus(USER_ID);
    expect(result.status).toBe(KycStatus.UNVERIFIED);
    expect(result.submittedAt).toBeNull();
  });

  it("maps an existing record", async () => {
    vi.mocked(kycRepository.findByUserId).mockResolvedValue(
      makeRecord({ status: KycStatus.REJECTED, rejectReason: "Ảnh mờ" }),
    );
    const result = await kycService.getStatus(USER_ID);
    expect(result.status).toBe(KycStatus.REJECTED);
    expect(result.rejectReason).toBe("Ảnh mờ");
  });
});

describe("kycService.review", () => {
  it("approves: VERIFIED record + user, no reject reason", async () => {
    vi.mocked(kycRepository.findById).mockResolvedValue(makeRecord());
    vi.mocked(kycRepository.updateReview).mockResolvedValue(
      makeRecord({ status: KycStatus.VERIFIED, reviewedBy: "admin-1" }),
    );

    await kycService.review("admin-1", "kyc-1", { decision: "approve" });

    expect(kycRepository.updateReview).toHaveBeenCalledWith(
      "kyc-1",
      expect.objectContaining({
        status: KycStatus.VERIFIED,
        reviewedBy: "admin-1",
        rejectReason: null,
      }),
    );
    expect(userRepository.updateKycStatus).toHaveBeenCalledWith(
      USER_ID,
      KycStatus.VERIFIED,
    );
  });

  it("rejects: REJECTED with the supplied reason", async () => {
    vi.mocked(kycRepository.findById).mockResolvedValue(makeRecord());
    vi.mocked(kycRepository.updateReview).mockResolvedValue(
      makeRecord({ status: KycStatus.REJECTED }),
    );

    await kycService.review("admin-1", "kyc-1", {
      decision: "reject",
      rejectReason: "Ảnh CCCD bị mờ",
    });

    expect(kycRepository.updateReview).toHaveBeenCalledWith(
      "kyc-1",
      expect.objectContaining({
        status: KycStatus.REJECTED,
        rejectReason: "Ảnh CCCD bị mờ",
      }),
    );
    expect(userRepository.updateKycStatus).toHaveBeenCalledWith(
      USER_ID,
      KycStatus.REJECTED,
    );
  });

  it("throws 404 when the KYC record does not exist", async () => {
    vi.mocked(kycRepository.findById).mockResolvedValue(null);
    await expect(
      kycService.review("admin-1", "missing", { decision: "approve" }),
    ).rejects.toBeInstanceOf(AppError);
    expect(kycRepository.updateReview).not.toHaveBeenCalled();
  });
});
