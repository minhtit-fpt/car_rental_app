import type { KYCVerification, KycStatus } from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho KYCVerification — CHỈ nơi đây gọi Prisma cho bảng này.

interface SubmissionDocuments {
  cccdUrl: string;
  licenseUrl: string;
  faceUrl: string;
}

interface ReviewData {
  status: KycStatus;
  reviewedBy: string;
  reviewedAt: Date;
  rejectReason: string | null;
}

export const kycRepository = {
  findByUserId(userId: string): Promise<KYCVerification | null> {
    return prisma.kYCVerification.findUnique({ where: { userId } });
  },

  findById(id: string): Promise<KYCVerification | null> {
    return prisma.kYCVerification.findUnique({ where: { id } });
  },

  // Nộp/nộp lại hồ sơ: tạo mới hoặc ghi đè, luôn đưa về PENDING và xóa dấu
  // vết duyệt cũ.
  upsertSubmission(
    userId: string,
    documents: SubmissionDocuments,
  ): Promise<KYCVerification> {
    return prisma.kYCVerification.upsert({
      where: { userId },
      create: { userId, ...documents, status: "PENDING" },
      update: {
        ...documents,
        status: "PENDING",
        reviewedBy: null,
        reviewedAt: null,
        rejectReason: null,
      },
    });
  },

  updateReview(id: string, data: ReviewData): Promise<KYCVerification> {
    return prisma.kYCVerification.update({ where: { id }, data });
  },
};
