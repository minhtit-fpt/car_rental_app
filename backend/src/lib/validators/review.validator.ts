import { z } from "zod";

// Zod schemas cho Review.

export const createReviewSchema = z.object({
  bookingId: z.string().uuid("bookingId không hợp lệ"),
  rating: z
    .number()
    .int("rating phải là số nguyên")
    .min(1, "rating tối thiểu 1")
    .max(5, "rating tối đa 5"),
  comment: z.string().trim().max(1000, "Nhận xét tối đa 1000 ký tự").optional(),
});

export const listReviewsQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

export type CreateReviewInput = z.infer<typeof createReviewSchema>;
export type ListReviewsQuery = z.infer<typeof listReviewsQuerySchema>;
