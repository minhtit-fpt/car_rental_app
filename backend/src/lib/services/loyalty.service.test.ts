import { beforeEach, describe, expect, it, vi } from "vitest";
import { type LoyaltyPoint } from "@prisma/client";

vi.mock("@/lib/repositories/loyalty.repository", () => ({
  loyaltyRepository: {
    findManyByUser: vi.fn(),
    sumPoints: vi.fn(),
  },
}));

import { loyaltyService } from "@/lib/services/loyalty.service";
import { loyaltyRepository } from "@/lib/repositories/loyalty.repository";

const USER = "user-1";

function makeEntry(overrides: Partial<LoyaltyPoint> = {}): LoyaltyPoint {
  return {
    id: "lp-1",
    userId: USER,
    points: 150,
    action: "BOOKING_COMPLETED",
    createdAt: new Date("2026-06-01T00:00:00Z"),
    ...overrides,
  } as LoyaltyPoint;
}

describe("loyaltyService.getSummary", () => {
  beforeEach(() => vi.clearAllMocks());

  it("computes GOLD tier with points toward PLATINUM", async () => {
    vi.mocked(loyaltyRepository.sumPoints).mockResolvedValue(2450);
    vi.mocked(loyaltyRepository.findManyByUser).mockResolvedValue({
      items: [makeEntry()],
      total: 1,
    });

    const result = await loyaltyService.getSummary(USER, { page: 1, limit: 20 });

    expect(result.totalPoints).toBe(2450);
    expect(result.tier).toBe("GOLD");
    expect(result.nextTier).toBe("PLATINUM");
    expect(result.pointsToNextTier).toBe(550);
    expect(result.history[0]?.points).toBe(150);
  });

  it("returns BRONZE with zero points and no negative remaining", async () => {
    vi.mocked(loyaltyRepository.sumPoints).mockResolvedValue(0);
    vi.mocked(loyaltyRepository.findManyByUser).mockResolvedValue({
      items: [],
      total: 0,
    });

    const result = await loyaltyService.getSummary(USER, { page: 1, limit: 20 });

    expect(result.tier).toBe("BRONZE");
    expect(result.nextTier).toBe("SILVER");
    expect(result.pointsToNextTier).toBe(1000);
  });

  it("returns PLATINUM with no next tier", async () => {
    vi.mocked(loyaltyRepository.sumPoints).mockResolvedValue(5000);
    vi.mocked(loyaltyRepository.findManyByUser).mockResolvedValue({
      items: [],
      total: 0,
    });

    const result = await loyaltyService.getSummary(USER, { page: 1, limit: 20 });

    expect(result.tier).toBe("PLATINUM");
    expect(result.nextTier).toBeNull();
    expect(result.pointsToNextTier).toBe(0);
  });
});
