import { z } from "zod";
import { normalizeVietnamPhone } from "@/lib/utils/phone";

// Zod schemas tại biên HTTP. Phone được chuẩn hóa về E.164 ngay khi validate.
// LƯU Ý: client KHÔNG được set roles — service luôn gán [RENTER] khi đăng ký.

const phoneField = z
  .string()
  .trim()
  .transform((value, ctx) => {
    const normalized = normalizeVietnamPhone(value);
    if (normalized === null) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: "Số điện thoại không hợp lệ",
      });
      return z.NEVER;
    }
    return normalized;
  });

// bcrypt chỉ băm 72 byte đầu → chặn ở 72 ký tự cho rõ ràng.
const passwordField = z
  .string()
  .min(8, "Mật khẩu phải tối thiểu 8 ký tự")
  .max(72, "Mật khẩu tối đa 72 ký tự");

export const registerSchema = z.object({
  phone: phoneField,
  password: passwordField,
  email: z.string().email("Email không hợp lệ").optional(),
});

export const loginSchema = z.object({
  phone: phoneField,
  password: z.string().min(1, "Mật khẩu là bắt buộc"),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(1, "refreshToken là bắt buộc"),
});

export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type RefreshInput = z.infer<typeof refreshSchema>;
