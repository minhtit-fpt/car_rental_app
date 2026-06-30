import type {
  DisputeStatus,
  KycStatus,
  Prisma,
  UserRole,
  VehicleApprovalStatus,
} from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho các truy vấn tổng hợp của ADMIN (stats / users / KYC queue).
// CHỈ nơi đây gọi Prisma cho các truy vấn admin.

export interface UserListFilter {
  skip: number;
  take: number;
  role?: UserRole;
  search?: string;
}

function buildUserWhere(filter: UserListFilter): Prisma.UserWhereInput {
  const where: Prisma.UserWhereInput = {};
  if (filter.role) {
    where.roles = { has: filter.role };
  }
  if (filter.search) {
    where.OR = [
      { phone: { contains: filter.search, mode: "insensitive" } },
      { email: { contains: filter.search, mode: "insensitive" } },
    ];
  }
  return where;
}

// Các trường user trả về cho danh sách/chi tiết quản trị (dùng lại cho cả update).
const adminUserSelect = {
  id: true,
  phone: true,
  email: true,
  roles: true,
  kycStatus: true,
  createdAt: true,
} satisfies Prisma.UserSelect;

export const adminRepository = {
  countUsers(): Promise<number> {
    return prisma.user.count();
  },

  // "Đang hoạt động" = đã xác nhận hoặc đang trong chuyến.
  countActiveBookings(): Promise<number> {
    return prisma.booking.count({
      where: { status: { in: ["CONFIRMED", "IN_PROGRESS"] } },
    });
  },

  countPendingKyc(): Promise<number> {
    return prisma.kYCVerification.count({ where: { status: "PENDING" } });
  },

  async sumRevenueSince(since: Date): Promise<number> {
    const result = await prisma.payment.aggregate({
      _sum: { amount: true },
      where: { status: "PAID", paidAt: { gte: since } },
    });
    return result._sum.amount?.toNumber() ?? 0;
  },

  // Doanh thu PAID gộp theo tháng (date_trunc) kể từ `since`. Các tháng không
  // có thanh toán sẽ thiếu — tầng service tự bù 0 để chuỗi liền mạch.
  monthlyRevenue(since: Date): Promise<{ month: Date; total: number }[]> {
    return prisma.$queryRaw<{ month: Date; total: number }[]>`
      SELECT date_trunc('month', "paidAt") AS month,
             COALESCE(SUM("amount"), 0)::float8 AS total
      FROM "Payment"
      WHERE "status" = 'PAID' AND "paidAt" >= ${since}
      GROUP BY 1
      ORDER BY 1 ASC
    `;
  },

  findUsers(filter: UserListFilter) {
    const where = buildUserWhere(filter);
    return prisma.$transaction([
      prisma.user.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip: filter.skip,
        take: filter.take,
        select: adminUserSelect,
      }),
      prisma.user.count({ where }),
    ]);
  },

  findUserById(id: string) {
    return prisma.user.findUnique({
      where: { id },
      select: { id: true, roles: true },
    });
  },

  // Ghi đè roles[] + ghi AuditLog trong cùng transaction. `action` mô tả
  // thao tác (USER_ROLE_ADD / USER_ROLE_REMOVE), `role` lưu vào metadata.
  setUserRoles(
    id: string,
    roles: UserRole[],
    adminId: string,
    action: string,
    role: UserRole,
  ) {
    return prisma.$transaction(async (tx) => {
      const updated = await tx.user.update({
        where: { id },
        data: { roles },
        select: adminUserSelect,
      });
      await tx.auditLog.create({
        data: {
          actorId: adminId,
          action,
          target: `user:${id}`,
          metadata: { role },
        },
      });
      return updated;
    });
  },

  findKycQueue(status: KycStatus, skip: number, take: number) {
    const where: Prisma.KYCVerificationWhereInput = { status };
    return prisma.$transaction([
      prisma.kYCVerification.findMany({
        where,
        orderBy: { createdAt: "asc" },
        skip,
        take,
        select: {
          id: true,
          userId: true,
          status: true,
          createdAt: true,
          user: { select: { phone: true, email: true } },
        },
      }),
      prisma.kYCVerification.count({ where }),
    ]);
  },

  findDisputes(status: DisputeStatus, skip: number, take: number) {
    const where: Prisma.DisputeWhereInput = { status };
    return prisma.$transaction([
      prisma.dispute.findMany({
        where,
        // Ưu tiên cao trước (HIGH < MEDIUM < LOW theo thứ tự enum), mới trước.
        orderBy: [{ priority: "asc" }, { createdAt: "desc" }],
        skip,
        take,
        select: {
          id: true,
          bookingId: true,
          title: true,
          priority: true,
          status: true,
          createdAt: true,
        },
      }),
      prisma.dispute.count({ where }),
    ]);
  },

  findDisputeById(id: string) {
    return prisma.dispute.findUnique({
      where: { id },
      select: { id: true, raisedById: true, status: true },
    });
  },

  // Đổi trạng thái dispute + ghi AuditLog trong cùng transaction (nguyên tử).
  resolveDispute(
    id: string,
    status: DisputeStatus,
    adminId: string,
    note?: string,
  ) {
    return prisma.$transaction(async (tx) => {
      const updated = await tx.dispute.update({
        where: { id },
        data: { status },
        select: { id: true, status: true },
      });
      await tx.auditLog.create({
        data: {
          actorId: adminId,
          action: `DISPUTE_${status}`,
          target: `dispute:${id}`,
          metadata: note ? { note } : undefined,
        },
      });
      return updated;
    });
  },

  // ── Phase 1: aggregation cho dashboard metrics ──────────────────────────

  groupBookingsByStatus() {
    return prisma.booking.groupBy({ by: ["status"], _count: { _all: true } });
  },

  groupPaymentsByMethodPaid() {
    return prisma.payment.groupBy({
      by: ["method"],
      where: { status: "PAID" },
      _sum: { amount: true },
    });
  },

  // [type, isElectric] → tầng service gộp thành { type, count, electric }.
  groupVehiclesByTypeElectric() {
    return prisma.vehicle.groupBy({
      by: ["type", "isElectric"],
      _count: { _all: true },
    });
  },

  countAvailableVehicles(): Promise<number> {
    return prisma.vehicle.count({ where: { isAvailable: true } });
  },

  async avgReviewRating(): Promise<number> {
    const result = await prisma.review.aggregate({ _avg: { rating: true } });
    return result._avg.rating ?? 0;
  },

  // Top xe theo doanh thu PAID (kèm số chuyến đã thanh toán). limit nhỏ.
  topVehiclesByRevenue(
    limit: number,
  ): Promise<{ id: string; title: string; revenue: number; trips: number }[]> {
    return prisma.$queryRaw`
      SELECT v.id, v.title,
             COALESCE(SUM(p."amount"), 0)::float8 AS revenue,
             COUNT(p.id)::int AS trips
      FROM "Vehicle" v
      JOIN "Booking" b ON b."vehicleId" = v.id
      JOIN "Payment" p ON p."bookingId" = b.id AND p."status" = 'PAID'
      GROUP BY v.id, v.title
      ORDER BY revenue DESC
      LIMIT ${limit}
    `;
  },

  // ── Phase 2: duyệt xe ───────────────────────────────────────────────────

  findVehiclesForReview(status: VehicleApprovalStatus, skip: number, take: number) {
    const where: Prisma.VehicleWhereInput = { approvalStatus: status };
    return prisma.$transaction([
      prisma.vehicle.findMany({
        where,
        orderBy: { createdAt: "asc" },
        skip,
        take,
        select: {
          id: true,
          title: true,
          type: true,
          pricePerHour: true,
          isElectric: true,
          city: true,
          approvalStatus: true,
          rejectionReason: true,
          createdAt: true,
          owner: { select: { id: true, phone: true, email: true } },
        },
      }),
      prisma.vehicle.count({ where }),
    ]);
  },

  findVehicleOwner(id: string) {
    return prisma.vehicle.findUnique({
      where: { id },
      select: { id: true, ownerId: true, title: true },
    });
  },

  // Đổi trạng thái duyệt + lý do + ghi AuditLog (nguyên tử).
  setVehicleApproval(
    id: string,
    status: VehicleApprovalStatus,
    adminId: string,
    rejectionReason: string | null,
  ) {
    return prisma.$transaction(async (tx) => {
      const updated = await tx.vehicle.update({
        where: { id },
        data: { approvalStatus: status, rejectionReason },
        select: { id: true, approvalStatus: true, rejectionReason: true },
      });
      await tx.auditLog.create({
        data: {
          actorId: adminId,
          action: `VEHICLE_${status}`,
          target: `vehicle:${id}`,
          metadata: rejectionReason ? { rejectionReason } : undefined,
        },
      });
      return updated;
    });
  },

  recentBookings(limit: number) {
    return prisma.booking.findMany({
      orderBy: { createdAt: "desc" },
      take: limit,
      select: {
        id: true,
        status: true,
        totalPrice: true,
        createdAt: true,
        vehicle: { select: { title: true } },
      },
    });
  },
};
