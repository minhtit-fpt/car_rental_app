import { z } from "zod";

// Zod schema cập nhật hồ sơ. Cho sửa email + tên hiển thị. Cho phép null để gỡ.
export const updateProfileSchema = z
  .object({
    email: z.string().email("Email không hợp lệ").nullable().optional(),
    name: z.string().trim().min(1, "Tên không hợp lệ").max(80).nullable().optional(),
  })
  .refine((v) => v.email !== undefined || v.name !== undefined, {
    message: "Không có trường nào để cập nhật",
  });

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
