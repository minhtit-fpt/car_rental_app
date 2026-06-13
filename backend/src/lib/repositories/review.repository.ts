import { type Prisma, type Review } from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho Review — CHỈ nơi đây gọi Prisma cho bảng Review.

export interface CreateReviewData {
  bookingId: string;
  reviewerId: string;
  targetId: string;
  rating: number;
  comment?: string;
}

export interface ListReviewsParams {
  targetId: string;
  page: number;
  limit: number;
}

export interface ReviewSummary {
  average: number;
  count: number;
}

export const reviewRepository = {
  create(data: CreateReviewData): Promise<Review> {
    return prisma.review.create({ data });
  },

  async findManyByTarget(
    p: ListReviewsParams,
  ): Promise<{ items: Review[]; total: number }> {
    const where: Prisma.ReviewWhereInput = { targetId: p.targetId };
    const [items, total] = await Promise.all([
      prisma.review.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip: (p.page - 1) * p.limit,
        take: p.limit,
      }),
      prisma.review.count({ where }),
    ]);
    return { items, total };
  },

  async summaryForTarget(targetId: string): Promise<ReviewSummary> {
    const result = await prisma.review.aggregate({
      where: { targetId },
      _avg: { rating: true },
      _count: { _all: true },
    });
    return {
      average: result._avg.rating ?? 0,
      count: result._count._all,
    };
  },
};
