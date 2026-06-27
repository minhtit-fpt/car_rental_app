import { randomUUID } from "node:crypto";
import type { InspectionPhase } from "@prisma/client";
import { AppError } from "@/lib/errors/app-error";
import { bookingRepository } from "@/lib/repositories/booking.repository";
import { inspectionRepository } from "@/lib/repositories/inspection.repository";
import { storage } from "@/lib/storage";
import {
  vlmClient,
  type DamageAnalysis,
  type InspectionImage,
} from "@/lib/ai/vlm.client";
import type {
  InspectionUploadUrlInput,
  SubmitInspectionInput,
} from "@/lib/validators/inspection.validator";

// ponytail: ảnh kiểm tra dùng chung bucket private với KYC (storage port chỉ có
// 1 bucket). Tách bucket riêng khi cần phân quyền/retention khác.
function inspectionKeyPrefix(bookingId: string): string {
  return `inspections/${bookingId}/`;
}

const CONTENT_TYPE_EXT: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
};

const EXT_CONTENT_TYPE: Record<string, string> = {
  jpg: "image/jpeg",
  jpeg: "image/jpeg",
  png: "image/png",
};

export interface UploadUrlResult {
  uploadUrl: string;
  objectKey: string;
}

export interface DamageReportResult {
  summary: string;
  items: unknown;
  estimatedCost: number;
  createdAt: Date;
  beforePhotos: string[];
  afterPhotos: string[];
}

// Tải đơn và xác nhận người gọi là một bên của đơn (người thuê HOẶC chủ xe).
// Cả hai đều có mặt khi giao/trả xe nên đều được phép chụp ảnh kiểm tra.
async function loadBookingParty(bookingId: string, userId: string) {
  const booking = await bookingRepository.findByIdForOwner(bookingId);
  if (!booking) {
    throw new AppError(404, "BOOKING_NOT_FOUND", "Không tìm thấy đơn đặt");
  }
  if (booking.renterId !== userId && booking.vehicle.ownerId !== userId) {
    throw new AppError(403, "FORBIDDEN", "Bạn không thuộc đơn đặt này");
  }
  return booking;
}

function contentTypeFromKey(key: string): string {
  const ext = key.split(".").pop()?.toLowerCase() ?? "";
  return EXT_CONTENT_TYPE[ext] ?? "image/jpeg";
}

async function loadImages(photoKeys: string[]): Promise<InspectionImage[]> {
  return Promise.all(
    photoKeys.map(async (key) => ({
      contentType: contentTypeFromKey(key),
      bytes: await storage.getBytes(key),
    })),
  );
}

export const inspectionService = {
  // Cấp presigned PUT cho 1 ảnh. Key luôn nằm dưới prefix của đơn → submit về
  // sau kiểm tra quyền sở hữu.
  async createUploadUrl(
    userId: string,
    bookingId: string,
    input: InspectionUploadUrlInput,
  ): Promise<UploadUrlResult> {
    await loadBookingParty(bookingId, userId);
    const ext = CONTENT_TYPE_EXT[input.contentType] ?? "bin";
    const objectKey = `${inspectionKeyPrefix(bookingId)}${input.phase.toLowerCase()}/${randomUUID()}.${ext}`;
    const uploadUrl = await storage.presignUpload(objectKey);
    return { uploadUrl, objectKey };
  },

  // Lưu bộ ảnh đã upload cho một phase. Mọi key phải nằm dưới prefix của đơn.
  async submit(
    userId: string,
    bookingId: string,
    input: SubmitInspectionInput,
  ): Promise<{ phase: InspectionPhase; photoCount: number }> {
    await loadBookingParty(bookingId, userId);
    const prefix = inspectionKeyPrefix(bookingId);
    for (const key of input.photoKeys) {
      if (!key.startsWith(prefix)) {
        throw new AppError(403, "FORBIDDEN", "Ảnh không thuộc đơn đặt này");
      }
    }
    const record = await inspectionRepository.upsertInspection(
      bookingId,
      input.phase,
      input.photoKeys,
      userId,
    );
    return { phase: record.phase, photoCount: record.photoKeys.length };
  },

  // So ảnh CHECKIN ↔ CHECKOUT bằng VLM → lưu báo cáo hư hỏng. Cần đủ cả hai bộ.
  async analyzeDamage(
    userId: string,
    bookingId: string,
  ): Promise<DamageReportResult> {
    await loadBookingParty(bookingId, userId);
    const [checkin, checkout] = await Promise.all([
      inspectionRepository.findInspection(bookingId, "CHECKIN"),
      inspectionRepository.findInspection(bookingId, "CHECKOUT"),
    ]);
    if (!checkin || !checkout) {
      throw new AppError(
        409,
        "INSPECTION_INCOMPLETE",
        "Cần đủ ảnh nhận xe và trả xe trước khi phân tích",
      );
    }

    const [before, after] = await Promise.all([
      loadImages(checkin.photoKeys),
      loadImages(checkout.photoKeys),
    ]);
    const analysis: DamageAnalysis = await vlmClient.analyzeDamage(
      before,
      after,
    );

    await inspectionRepository.upsertDamageReport(bookingId, {
      summary: analysis.summary,
      items: analysis.items,
      estimatedCost: analysis.estimatedCost,
    });

    return this.getReport(userId, bookingId);
  },

  // Lấy báo cáo + presigned GET cho ảnh hai phase để FE hiển thị.
  async getReport(
    userId: string,
    bookingId: string,
  ): Promise<DamageReportResult> {
    await loadBookingParty(bookingId, userId);
    const report = await inspectionRepository.findDamageReport(bookingId);
    if (!report) {
      throw new AppError(
        404,
        "DAMAGE_REPORT_NOT_FOUND",
        "Chưa có báo cáo hư hỏng cho đơn này",
      );
    }
    const [checkin, checkout] = await Promise.all([
      inspectionRepository.findInspection(bookingId, "CHECKIN"),
      inspectionRepository.findInspection(bookingId, "CHECKOUT"),
    ]);
    const [beforePhotos, afterPhotos] = await Promise.all([
      Promise.all(
        (checkin?.photoKeys ?? []).map((k) => storage.presignDownload(k)),
      ),
      Promise.all(
        (checkout?.photoKeys ?? []).map((k) => storage.presignDownload(k)),
      ),
    ]);

    return {
      summary: report.summary,
      items: report.items,
      estimatedCost: report.estimatedCost,
      createdAt: report.createdAt,
      beforePhotos,
      afterPhotos,
    };
  },
};
