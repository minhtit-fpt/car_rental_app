import { z } from "zod";

// Zod schema cập nhật hồ sơ. MVP chỉ cho sửa email (field an toàn, không đổi
// schema). Cho phép null để gỡ email.
export const updateProfileSchema = z
  .object({
    email: z.string().email("Email không hợp lệ").nullable().optional(),
  })
  .refine((v) => v.email !== undefined, {
    message: "Không có trường nào để cập nhật",
  });

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
