import { z } from "zod";

// Zod schemas cho Payment.

export const createPaymentSchema = z.object({
  bookingId: z.string().uuid("bookingId không hợp lệ"),
});

// Mô phỏng callback từ cổng (mock-first). Adapter thật sẽ nhận IPN có chữ ký.
export const confirmPaymentSchema = z.object({
  success: z.boolean().default(true),
});

export type CreatePaymentInput = z.infer<typeof createPaymentSchema>;
export type ConfirmPaymentInput = z.infer<typeof confirmPaymentSchema>;
