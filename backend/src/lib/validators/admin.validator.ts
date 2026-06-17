import { z } from "zod";
import { DisputeStatus, KycStatus, UserRole } from "@prisma/client";

// Query params đến dưới dạng string → coerce sang số; có default an toàn.

const pagination = {
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
};

export const listUsersSchema = z.object({
  ...pagination,
  role: z.nativeEnum(UserRole).optional(),
  search: z.string().trim().min(1).max(100).optional(),
});
export type ListUsersInput = z.infer<typeof listUsersSchema>;

export const listKycSchema = z.object({
  ...pagination,
  status: z.nativeEnum(KycStatus).default(KycStatus.PENDING),
});
export type ListKycInput = z.infer<typeof listKycSchema>;

// Số tháng gần nhất cho biểu đồ doanh thu (mặc định 6).
export const revenueQuerySchema = z.object({
  months: z.coerce.number().int().min(1).max(24).default(6),
});
export type RevenueQuery = z.infer<typeof revenueQuerySchema>;

export const listDisputesSchema = z.object({
  ...pagination,
  status: z.nativeEnum(DisputeStatus).default(DisputeStatus.OPEN),
});
export type ListDisputesInput = z.infer<typeof listDisputesSchema>;
