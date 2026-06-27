import { type LoyaltyPoint } from "@prisma/client";
import { loyaltyRepository } from "@/lib/repositories/loyalty.repository";
import type { ListLoyaltyQuery } from "@/lib/validators/loyalty.validator";

export interface LoyaltyEntry {
  id: string;
  points: number;
  action: string;
  createdAt: string;
}

export type LoyaltyTier = "BRONZE" | "SILVER" | "GOLD" | "PLATINUM";

export interface LoyaltySummary {
  totalPoints: number;
  tier: LoyaltyTier;
  nextTier: LoyaltyTier | null;
  pointsToNextTier: number;
  history: LoyaltyEntry[];
  total: number; // tổng số bản ghi lịch sử
  page: number;
  limit: number;
}

// Ngưỡng điểm cho từng hạng (điểm tích lũy hiện có).
const TIERS: { tier: LoyaltyTier; min: number }[] = [
  { tier: "BRONZE", min: 0 },
  { tier: "SILVER", min: 1000 },
  { tier: "GOLD", min: 2000 },
  { tier: "PLATINUM", min: 3000 },
];

function resolveTier(points: number): {
  tier: LoyaltyTier;
  nextTier: LoyaltyTier | null;
  pointsToNextTier: number;
} {
  let current = TIERS[0]!;
  let next: { tier: LoyaltyTier; min: number } | null = null;
  for (let i = 0; i < TIERS.length; i += 1) {
    if (points >= TIERS[i]!.min) {
      current = TIERS[i]!;
      next = TIERS[i + 1] ?? null;
    }
  }
  return {
    tier: current.tier,
    nextTier: next ? next.tier : null,
    pointsToNextTier: next ? Math.max(0, next.min - points) : 0,
  };
}

function toEntry(p: LoyaltyPoint): LoyaltyEntry {
  return {
    id: p.id,
    points: p.points,
    action: p.action,
    createdAt: p.createdAt.toISOString(),
  };
}

export const loyaltyService = {
  async getSummary(
    userId: string,
    query: ListLoyaltyQuery,
  ): Promise<LoyaltySummary> {
    const [totalPoints, { items, total }] = await Promise.all([
      loyaltyRepository.sumPoints(userId),
      loyaltyRepository.findManyByUser({ userId, ...query }),
    ]);
    const { tier, nextTier, pointsToNextTier } = resolveTier(totalPoints);
    return {
      totalPoints,
      tier,
      nextTier,
      pointsToNextTier,
      history: items.map(toEntry),
      total,
      page: query.page,
      limit: query.limit,
    };
  },
};
