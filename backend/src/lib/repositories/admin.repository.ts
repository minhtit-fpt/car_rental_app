import type {
  BookingStatus,
  DisputeStatus,
  KycStatus,
  Prisma,
  UserRole,
  VehicleApprovalStatus,
} from "@prisma/client";
import { PaymentStatus } from "@prisma/client";
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
          pricePerDay: true,
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

  // ── Phase 5b: facts cho rule-engine chấm điểm rủi ro ────────────────────
  // 1 query gom facts mỗi user (non-admin) qua CTE để tránh fan-out khi join
  // nhiều bảng. ponytail: full scan toàn bộ user — ổn ở quy mô này; thêm
  // prefilter ứng viên nếu số user lớn lên.
  getUserRiskFacts(): Promise<
    {
      id: string;
      phone: string;
      email: string | null;
      roles: UserRole[];
      createdAt: Date;
      total_bookings: number;
      cancelled: number;
      completed: number;
      max_value: number;
      self_rentals: number;
      failed: number;
      owned_total: number;
      owned_completed: number;
    }[]
  > {
    return prisma.$queryRaw`
      WITH renter_stats AS (
        SELECT b."renterId" AS uid,
               COUNT(*)::int AS total_bookings,
               COUNT(*) FILTER (WHERE b.status = 'CANCELLED')::int AS cancelled,
               COUNT(*) FILTER (WHERE b.status = 'COMPLETED')::int AS completed,
               COALESCE(MAX(b."totalPrice"), 0)::float8 AS max_value,
               COUNT(*) FILTER (WHERE v."ownerId" = b."renterId")::int AS self_rentals
        FROM "Booking" b
        JOIN "Vehicle" v ON v.id = b."vehicleId"
        GROUP BY b."renterId"
      ),
      fail_stats AS (
        SELECT b."renterId" AS uid, COUNT(*)::int AS failed
        FROM "Payment" p
        JOIN "Booking" b ON b.id = p."bookingId"
        WHERE p.status = 'FAILED'
        GROUP BY b."renterId"
      ),
      owner_stats AS (
        SELECT v."ownerId" AS uid,
               COUNT(b.id)::int AS owned_total,
               COUNT(b.id) FILTER (WHERE b.status = 'COMPLETED')::int AS owned_completed
        FROM "Vehicle" v
        LEFT JOIN "Booking" b ON b."vehicleId" = v.id
        GROUP BY v."ownerId"
      )
      SELECT u.id, u.phone, u.email, u.roles, u."createdAt",
             COALESCE(r.total_bookings, 0) AS total_bookings,
             COALESCE(r.cancelled, 0) AS cancelled,
             COALESCE(r.completed, 0) AS completed,
             COALESCE(r.max_value, 0) AS max_value,
             COALESCE(r.self_rentals, 0) AS self_rentals,
             COALESCE(f.failed, 0) AS failed,
             COALESCE(o.owned_total, 0) AS owned_total,
             COALESCE(o.owned_completed, 0) AS owned_completed
      FROM "User" u
      LEFT JOIN renter_stats r ON r.uid = u.id
      LEFT JOIN fail_stats f ON f.uid = u.id
      LEFT JOIN owner_stats o ON o.uid = u.id
      WHERE NOT (u.roles @> ARRAY['ADMIN']::"UserRole"[])
    `;
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

  // ── Phase 3: quản lý đơn / thanh toán + hoàn tiền ───────────────────────

  findBookings(filter: {
    status?: BookingStatus;
    from?: Date;
    to?: Date;
    skip: number;
    take: number;
  }) {
    const where: Prisma.BookingWhereInput = {};
    if (filter.status) where.status = filter.status;
    if (filter.from || filter.to) {
      where.createdAt = {};
      if (filter.from) where.createdAt.gte = filter.from;
      if (filter.to) where.createdAt.lte = filter.to;
    }
    return prisma.$transaction([
      prisma.booking.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip: filter.skip,
        take: filter.take,
        select: {
          id: true,
          status: true,
          totalPrice: true,
          startTime: true,
          endTime: true,
          createdAt: true,
          vehicle: { select: { title: true } },
          payment: { select: { status: true } },
        },
      }),
      prisma.booking.count({ where }),
    ]);
  },

  findBookingDetail(id: string) {
    return prisma.booking.findUnique({
      where: { id },
      select: {
        id: true,
        status: true,
        startTime: true,
        endTime: true,
        totalPrice: true,
        deliveryRequested: true,
        createdAt: true,
        vehicle: { select: { id: true, title: true, type: true } },
        renter: { select: { id: true, phone: true, email: true } },
        payment: {
          select: {
            method: true,
            status: true,
            amount: true,
            gatewayRef: true,
            paidAt: true,
          },
        },
        contract: { select: { pdfUrl: true, signedAt: true } },
        inspections: {
          orderBy: { createdAt: "asc" },
          select: { phase: true, photoKeys: true, createdAt: true },
        },
        disputes: {
          orderBy: { createdAt: "desc" },
          select: {
            id: true,
            title: true,
            status: true,
            priority: true,
            createdAt: true,
          },
        },
        damageReport: { select: { summary: true, estimatedCost: true } },
      },
    });
  },

  // Phase 4: gom toàn bộ ngữ cảnh một tranh chấp cho trợ lý AI — fact cứng
  // (đã ký? đã trả? hư hỏng?) + transcript chat. KHÔNG lộ photoKeys.
  findDisputeContext(disputeId: string) {
    return prisma.dispute.findUnique({
      where: { id: disputeId },
      select: {
        id: true,
        title: true,
        description: true,
        status: true,
        priority: true,
        createdAt: true,
        raisedById: true,
        booking: {
          select: {
            id: true,
            status: true,
            startTime: true,
            endTime: true,
            totalPrice: true,
            createdAt: true,
            renterId: true,
            vehicle: { select: { title: true, ownerId: true } },
            payment: { select: { status: true, amount: true, paidAt: true } },
            contract: { select: { signedAt: true } },
            inspections: { select: { phase: true } },
            damageReport: {
              select: { summary: true, items: true, estimatedCost: true },
            },
            conversation: {
              select: {
                messages: {
                  orderBy: { sentAt: "asc" },
                  take: 30,
                  select: { senderId: true, body: true, sentAt: true },
                },
              },
            },
          },
        },
      },
    });
  },

  // Đủ dữ liệu để service quyết định + báo người thuê khi hoàn tiền.
  findBookingForRefund(id: string) {
    return prisma.booking.findUnique({
      where: { id },
      select: {
        id: true,
        renterId: true,
        payment: { select: { status: true, amount: true } },
      },
    });
  },

  // Đánh dấu Payment.status = REFUNDED + ghi AuditLog (nguyên tử). KHÔNG gọi
  // cổng thanh toán thật trong đợt này — tích hợp gateway sau.
  refundPayment(
    bookingId: string,
    amount: number,
    adminId: string,
    reason: string,
  ) {
    return prisma.$transaction(async (tx) => {
      const updated = await tx.payment.update({
        where: { bookingId },
        data: { status: PaymentStatus.REFUNDED },
        select: { status: true },
      });
      await tx.auditLog.create({
        data: {
          actorId: adminId,
          action: "PAYMENT_REFUNDED",
          target: `booking:${bookingId}`,
          metadata: { amount, reason },
        },
      });
      return updated;
    });
  },
};
