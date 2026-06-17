import { z } from "zod";

// Zod schemas cho Payment.

export const createPaymentSchema = z.object({
  bookingId: z.string().uuid("bookingId không hợp lệ"),
});

// Callback từ cổng. Mock dùng cờ `success`; VNPay thật gửi `params` (vnp_*) để
// adapter tính lại HMAC và xác thực vnp_SecureHash.
export const confirmPaymentSchema = z.object({
  success: z.boolean().default(true),
  params: z.record(z.string()).optional(),
});

export type CreatePaymentInput = z.infer<typeof createPaymentSchema>;
export type ConfirmPaymentInput = z.infer<typeof confirmPaymentSchema>;
