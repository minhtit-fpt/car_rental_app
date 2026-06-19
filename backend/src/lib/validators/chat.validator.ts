import { z } from "zod";

// Zod schemas cho Chat.

export const createConversationSchema = z
  .object({
    participantId: z.string().uuid("participantId không hợp lệ").optional(),
    bookingId: z.string().uuid("bookingId không hợp lệ").optional(),
  })
  .refine((v) => v.participantId || v.bookingId, {
    message: "Cần participantId hoặc bookingId",
  });

export const listMessagesQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(30),
});

export const sendMessageSchema = z.object({
  body: z
    .string()
    .trim()
    .min(1, "Tin nhắn không được để trống")
    .max(2000, "Tin nhắn tối đa 2000 ký tự"),
});

export type CreateConversationInput = z.infer<typeof createConversationSchema>;
export type ListMessagesQuery = z.infer<typeof listMessagesQuerySchema>;
export type SendMessageInput = z.infer<typeof sendMessageSchema>;
