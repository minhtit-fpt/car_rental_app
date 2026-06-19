import { z } from "zod";

// Zod schemas cho Community (TripStory).

export const listStoriesQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(50).default(20),
});

export const createStorySchema = z.object({
  content: z
    .string()
    .trim()
    .min(1, "Nội dung không được để trống")
    .max(2000, "Nội dung tối đa 2000 ký tự"),
  images: z
    .array(z.string().url("URL ảnh không hợp lệ"))
    .max(10, "Tối đa 10 ảnh")
    .default([]),
  bookingId: z.string().uuid("bookingId không hợp lệ").optional(),
});

export type ListStoriesQuery = z.infer<typeof listStoriesQuerySchema>;
export type CreateStoryInput = z.infer<typeof createStorySchema>;
