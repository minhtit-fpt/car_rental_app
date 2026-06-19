import { type LoyaltyPoint } from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho LoyaltyPoint — CHỈ nơi đây gọi Prisma cho bảng LoyaltyPoint.

export interface ListLoyaltyParams {
  userId: string;
  page: number;
  limit: number;
}

export const loyaltyRepository = {
  async findManyByUser(
    p: ListLoyaltyParams,
  ): Promise<{ items: LoyaltyPoint[]; total: number }> {
    const where = { userId: p.userId };
    const [items, total] = await Promise.all([
      prisma.loyaltyPoint.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip: (p.page - 1) * p.limit,
        take: p.limit,
      }),
      prisma.loyaltyPoint.count({ where }),
    ]);
    return { items, total };
  },

  // Tổng điểm hiện có (có thể âm khi tiêu điểm vượt tích lũy — không kỳ vọng).
  async sumPoints(userId: string): Promise<number> {
    const result = await prisma.loyaltyPoint.aggregate({
      where: { userId },
      _sum: { points: true },
    });
    return result._sum.points ?? 0;
  },
};
