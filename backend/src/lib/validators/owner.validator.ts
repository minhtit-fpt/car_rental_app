import { z } from "zod";

// Số tháng cho chuỗi doanh thu owner (mặc định 6, tối đa 24).
export const ownerRevenueQuerySchema = z.object({
  months: z.coerce.number().int().positive().max(24).default(6),
});

export type OwnerRevenueQuery = z.infer<typeof ownerRevenueQuerySchema>;
