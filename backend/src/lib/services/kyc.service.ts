import { randomUUID } from "node:crypto";
import type { KYCVerification } from "@prisma/client";
import { KycStatus } from "@prisma/client";
import { AppError } from "@/lib/errors/app-error";
import { kycRepository } from "@/lib/repositories/kyc.repository";
import { userRepository } from "@/lib/repositories/user.repository";
import { storage } from "@/lib/storage";
import type {
  ReviewKycInput,
  SubmitKycInput,
  UploadUrlInput,
} from "@/lib/validators/kyc.validator";

// Prefix khóa đối tượng theo user — ảnh KYC luôn nằm dưới kyc/{userId}/.
// Dùng để chặn việc submit object key của user khác.
export function kycKeyPrefix(userId: string): string {
  return `kyc/${userId}/`;
}

export interface KycStatusResult {
  status: KycStatus;
  rejectReason: string | null;
  reviewedAt: Date | null;
  submittedAt: Date | null;
}

export interface UploadUrlResult {
  uploadUrl: string;
  objectKey: string;
}

export interface ReviewDocuments {
  cccdUrl: string;
  licenseUrl: string;
  faceUrl: string;
}

const CONTENT_TYPE_EXT: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
};

function assertOwnedKey(userId: string, key: string): void {
  if (!key.startsWith(kycKeyPrefix(userId))) {
    throw new AppError(403, "FORBIDDEN", "Object key không thuộc về bạn");
  }
}

export const kycService = {
  // Cấp presigned PUT cho client upload thẳng 1 ảnh lên bucket private.
  // Key luôn nằm dưới prefix của user → submit về sau sẽ kiểm tra quyền sở hữu.
  async createUploadUrl(
    userId: string,
    input: UploadUrlInput,
  ): Promise<UploadUrlResult> {
    const ext = CONTENT_TYPE_EXT[input.contentType] ?? "bin";
    const objectKey = `${kycKeyPrefix(userId)}${input.docType}-${randomUUID()}.${ext}`;
    const uploadUrl = await storage.presignUpload(objectKey);
    return { uploadUrl, objectKey };
  },

  // Nộp hồ sơ KYC: xác minh các key thuộc về user → lưu hồ sơ (PENDING) →
  // đồng bộ kycStatus trên User.
  async submit(
    userId: string,
    input: SubmitKycInput,
  ): Promise<KYCVerification> {
    assertOwnedKey(userId, input.cccdKey);
    assertOwnedKey(userId, input.licenseKey);
    assertOwnedKey(userId, input.faceKey);

    const record = await kycRepository.upsertSubmission(userId, {
      cccdUrl: input.cccdKey,
      licenseUrl: input.licenseKey,
      faceUrl: input.faceKey,
    });
    await userRepository.updateKycStatus(userId, KycStatus.PENDING);

    return record;
  },

  async getStatus(userId: string): Promise<KycStatusResult> {
    const record = await kycRepository.findByUserId(userId);
    if (!record) {
      return {
        status: KycStatus.UNVERIFIED,
        rejectReason: null,
        reviewedAt: null,
        submittedAt: null,
      };
    }
    return {
      status: record.status,
      rejectReason: record.rejectReason,
      reviewedAt: record.reviewedAt,
      submittedAt: record.createdAt,
    };
  },

  // ADMIN duyệt/từ chối. Cập nhật hồ sơ + đồng bộ kycStatus trên User.
  async review(
    adminId: string,
    kycId: string,
    input: ReviewKycInput,
  ): Promise<KYCVerification> {
    const record = await kycRepository.findById(kycId);
    if (!record) {
      throw new AppError(404, "KYC_NOT_FOUND", "Không tìm thấy hồ sơ KYC");
    }

    const approved = input.decision === "approve";
    const status = approved ? KycStatus.VERIFIED : KycStatus.REJECTED;

    const updated = await kycRepository.updateReview(kycId, {
      status,
      reviewedBy: adminId,
      reviewedAt: new Date(),
      rejectReason: approved ? null : (input.rejectReason ?? null),
    });
    await userRepository.updateKycStatus(record.userId, status);

    return updated;
  },

  // ADMIN xem ảnh khi duyệt: trả presigned GET ngắn hạn cho cả 3 giấy tờ.
  // Không bao giờ trả raw object key/public URL ra ngoài.
  async getReviewDocuments(kycId: string): Promise<ReviewDocuments> {
    const record = await kycRepository.findById(kycId);
    if (!record) {
      throw new AppError(404, "KYC_NOT_FOUND", "Không tìm thấy hồ sơ KYC");
    }
    const [cccdUrl, licenseUrl, faceUrl] = await Promise.all([
      storage.presignDownload(record.cccdUrl),
      storage.presignDownload(record.licenseUrl),
      storage.presignDownload(record.faceUrl),
    ]);
    return { cccdUrl, licenseUrl, faceUrl };
  },
};
