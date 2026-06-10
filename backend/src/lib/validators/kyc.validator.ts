import { z } from "zod";

// Zod schemas cho luồng KYC tại biên HTTP.
// docType: loại giấy tờ. contentType: chỉ chấp nhận ảnh JPEG/PNG.
// objectKey: do server cấp khi presign; client gửi lại đúng key đó khi submit.

export const kycDocTypeSchema = z.enum(["cccd", "license", "face"]);

const ALLOWED_CONTENT_TYPES = ["image/jpeg", "image/png"] as const;

const contentTypeField = z.enum(ALLOWED_CONTENT_TYPES, {
  errorMap: () => ({ message: "Chỉ chấp nhận ảnh JPEG hoặc PNG" }),
});

export const uploadUrlSchema = z.object({
  docType: kycDocTypeSchema,
  contentType: contentTypeField,
});

const objectKeyField = z
  .string()
  .trim()
  .min(1, "objectKey là bắt buộc")
  .max(255, "objectKey quá dài");

export const submitKycSchema = z.object({
  cccdKey: objectKeyField,
  licenseKey: objectKeyField,
  faceKey: objectKeyField,
});

// Khi từ chối (reject) bắt buộc có lý do; khi duyệt (approve) thì không cần.
export const reviewKycSchema = z
  .object({
    decision: z.enum(["approve", "reject"]),
    rejectReason: z.string().trim().min(1).max(500).optional(),
  })
  .refine((value) => value.decision === "approve" || !!value.rejectReason, {
    message: "rejectReason là bắt buộc khi từ chối",
    path: ["rejectReason"],
  });

export type KycDocType = z.infer<typeof kycDocTypeSchema>;
export type UploadUrlInput = z.infer<typeof uploadUrlSchema>;
export type SubmitKycInput = z.infer<typeof submitKycSchema>;
export type ReviewKycInput = z.infer<typeof reviewKycSchema>;
