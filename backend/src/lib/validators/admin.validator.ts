import { z } from "zod";
import {
  DisputeStatus,
  KycStatus,
  UserRole,
  VehicleApprovalStatus,
} from "@prisma/client";

// Query params đến dưới dạng string → coerce sang số; có default an toàn.

const pagination = {
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
};

export const listUsersSchema = z.object({
  ...pagination,
  role: z.nativeEnum(UserRole).optional(),
  search: z.string().trim().min(1).max(100).optional(),
});
export type ListUsersInput = z.infer<typeof listUsersSchema>;

export const listKycSchema = z.object({
  ...pagination,
  status: z.nativeEnum(KycStatus).default(KycStatus.PENDING),
});
export type ListKycInput = z.infer<typeof listKycSchema>;

// Số tháng gần nhất cho biểu đồ doanh thu (mặc định 6).
export const revenueQuerySchema = z.object({
  months: z.coerce.number().int().min(1).max(24).default(6),
});
export type RevenueQuery = z.infer<typeof revenueQuerySchema>;

export const listDisputesSchema = z.object({
  ...pagination,
  status: z.nativeEnum(DisputeStatus).default(DisputeStatus.OPEN),
});
export type ListDisputesInput = z.infer<typeof listDisputesSchema>;

// ADMIN xử lý tranh chấp: resolve → RESOLVED, reject → REJECTED. `note` tuỳ chọn.
export const resolveDisputeSchema = z.object({
  decision: z.enum(["resolve", "reject"]),
  note: z.string().trim().min(1).max(500).optional(),
});
export type ResolveDisputeInput = z.infer<typeof resolveDisputeSchema>;

// ADMIN bật/tắt vai OWNER cho user. RENTER là mặc định, ADMIN tách biệt
// (CHECK user_admin_exclusive) nên chỉ OWNER mới toggle được.
export const updateUserRoleSchema = z.object({
  role: z.literal(UserRole.OWNER),
  action: z.enum(["add", "remove"]),
});
export type UpdateUserRoleInput = z.infer<typeof updateUserRoleSchema>;

// Hàng đợi duyệt xe (mặc định PENDING).
export const listVehiclesSchema = z.object({
  ...pagination,
  status: z
    .nativeEnum(VehicleApprovalStatus)
    .default(VehicleApprovalStatus.PENDING),
});
export type ListVehiclesInput = z.infer<typeof listVehiclesSchema>;

// ADMIN duyệt/từ chối xe. reject cần `rejectionReason`.
export const reviewVehicleSchema = z
  .object({
    decision: z.enum(["approve", "reject"]),
    rejectionReason: z.string().trim().min(1).max(500).optional(),
  })
  .refine((v) => v.decision === "approve" || !!v.rejectionReason, {
    message: "rejectionReason là bắt buộc khi từ chối",
    path: ["rejectionReason"],
  });
export type ReviewVehicleInput = z.infer<typeof reviewVehicleSchema>;
