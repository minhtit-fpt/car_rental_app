import { z } from "zod";

// Zod schemas cho luồng kiểm tra xe (check-in/check-out) tại biên HTTP.
// phase: nhận xe (CHECKIN) hay trả xe (CHECKOUT).
// contentType: chỉ chấp nhận ảnh JPEG/PNG.

export const inspectionPhaseSchema = z.enum(["CHECKIN", "CHECKOUT"]);

const ALLOWED_CONTENT_TYPES = ["image/jpeg", "image/png"] as const;

const contentTypeField = z.enum(ALLOWED_CONTENT_TYPES, {
  errorMap: () => ({ message: "Chỉ chấp nhận ảnh JPEG hoặc PNG" }),
});

export const inspectionUploadUrlSchema = z.object({
  phase: inspectionPhaseSchema,
  contentType: contentTypeField,
});

const objectKeyField = z
  .string()
  .trim()
  .min(1, "objectKey là bắt buộc")
  .max(255, "objectKey quá dài");

// Tối đa 8 ảnh/phase — đủ 4 góc + nội thất, tránh prompt VLM quá nặng.
export const submitInspectionSchema = z.object({
  phase: inspectionPhaseSchema,
  photoKeys: z
    .array(objectKeyField)
    .min(1, "Cần ít nhất 1 ảnh")
    .max(8, "Tối đa 8 ảnh mỗi lượt kiểm tra"),
});

export type InspectionPhaseInput = z.infer<typeof inspectionPhaseSchema>;
export type InspectionUploadUrlInput = z.infer<typeof inspectionUploadUrlSchema>;
export type SubmitInspectionInput = z.infer<typeof submitInspectionSchema>;
