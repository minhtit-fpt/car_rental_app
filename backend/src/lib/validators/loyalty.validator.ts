import { z } from "zod";

// Zod schema cho lịch sử điểm thưởng.

export const listLoyaltyQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

export type ListLoyaltyQuery = z.infer<typeof listLoyaltyQuerySchema>;
