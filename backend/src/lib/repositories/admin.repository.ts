import type { KycStatus, Prisma, UserRole } from "@prisma/client";
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

  findUsers(filter: UserListFilter) {
    const where = buildUserWhere(filter);
    return prisma.$transaction([
      prisma.user.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip: filter.skip,
        take: filter.take,
        select: {
          id: true,
          phone: true,
          email: true,
          roles: true,
          kycStatus: true,
          createdAt: true,
        },
      }),
      prisma.user.count({ where }),
    ]);
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
};
