import type {
  DamageReport,
  Inspection,
  InspectionPhase,
  Prisma,
} from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho Inspection + DamageReport — CHỈ nơi đây gọi Prisma cho
// hai bảng này.

interface DamageReportData {
  summary: string;
  items: Prisma.InputJsonValue;
  estimatedCost: number;
}

export const inspectionRepository = {
  // Lưu/ghi đè bộ ảnh kiểm tra cho một phase (mỗi đơn tối đa 1 bộ mỗi phase).
  upsertInspection(
    bookingId: string,
    phase: InspectionPhase,
    photoKeys: string[],
    createdById: string,
  ): Promise<Inspection> {
    return prisma.inspection.upsert({
      where: { bookingId_phase: { bookingId, phase } },
      create: { bookingId, phase, photoKeys, createdById },
      update: { photoKeys, createdById },
    });
  },

  findInspection(
    bookingId: string,
    phase: InspectionPhase,
  ): Promise<Inspection | null> {
    return prisma.inspection.findUnique({
      where: { bookingId_phase: { bookingId, phase } },
    });
  },

  // Ghi kết quả VLM soi hư hỏng cho 1 lượt (sau khi đã upsert ảnh).
  updateFindings(
    bookingId: string,
    phase: InspectionPhase,
    summary: string,
    items: Prisma.InputJsonValue,
  ): Promise<Inspection> {
    return prisma.inspection.update({
      where: { bookingId_phase: { bookingId, phase } },
      data: { findingsSummary: summary, findings: items, analyzedAt: new Date() },
    });
  },

  upsertDamageReport(
    bookingId: string,
    data: DamageReportData,
  ): Promise<DamageReport> {
    return prisma.damageReport.upsert({
      where: { bookingId },
      create: { bookingId, ...data },
      update: data,
    });
  },

  findDamageReport(bookingId: string): Promise<DamageReport | null> {
    return prisma.damageReport.findUnique({ where: { bookingId } });
  },
};
