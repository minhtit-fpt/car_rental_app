/**
 * Xuất snapshot dữ liệu admin ra `ai-service/data/admin_snapshot.json`.
 *
 * Chatbot admin ĐỌC file JSON này làm ngữ cảnh, KHÔNG tool-calling thẳng vào DB
 * (theo yêu cầu đề bài). Chạy tay để làm mới snapshot:
 *   npm run snapshot:admin
 *
 * Dữ liệu lấy qua `adminService` (cùng nguồn với API admin) → số liệu khớp
 * dashboard, không viết truy vấn hai lần.
 */
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";

import { prisma } from "@/db/prisma";
import { adminService } from "@/lib/services/admin.service";
import {
  listBookingsSchema,
  listDisputesSchema,
  listKycSchema,
  listUsersSchema,
} from "@/lib/validators/admin.validator";

// backend/scripts -> ai-service/data (cùng cây repo).
const OUT_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "ai-service",
  "data",
  "admin_snapshot.json",
);

// Đủ để trả lời câu hỏi tổng hợp mà không thổi phồng ngữ cảnh LLM.
const SAMPLE_LIMIT = 50;
const REVENUE_MONTHS = 6;

async function main(): Promise<void> {
  const [metrics, revenue, bookings, users, kyc, disputes, riskFlags] =
    await Promise.all([
      adminService.getMetrics(),
      adminService.getRevenueSeries(REVENUE_MONTHS),
      adminService.listBookings(listBookingsSchema.parse({ limit: SAMPLE_LIMIT })),
      adminService.listUsers(listUsersSchema.parse({ limit: SAMPLE_LIMIT })),
      adminService.listKyc(listKycSchema.parse({ limit: SAMPLE_LIMIT })),
      adminService.listDisputes(listDisputesSchema.parse({ limit: SAMPLE_LIMIT })),
      adminService.listRiskFlags(),
    ]);

  const snapshot = {
    generatedAt: new Date().toISOString(),
    metrics,
    revenue,
    bookings: bookings.items,
    users: users.items,
    kyc: kyc.items,
    disputes: disputes.items,
    riskFlags,
  };

  await mkdir(path.dirname(OUT_PATH), { recursive: true });
  await writeFile(OUT_PATH, JSON.stringify(snapshot, null, 2), "utf-8");
  console.log(`Snapshot admin đã ghi: ${OUT_PATH}`);
}

main()
  .catch((err) => {
    console.error("Xuất snapshot admin lỗi:", err);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
