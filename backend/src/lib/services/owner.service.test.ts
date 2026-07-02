import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/lib/repositories/owner.repository", () => ({
  ownerRepository: {
    sumPaidRevenue: vi.fn(),
    countPaidTrips: vi.fn(),
    monthlyRevenue: vi.fn(),
    recentTransactions: vi.fn(),
    perVehicleStats: vi.fn(),
  },
}));

import { ownerService } from "@/lib/services/owner.service";
import { ownerRepository } from "@/lib/repositories/owner.repository";

beforeEach(() => {
  vi.clearAllMocks();
  vi.mocked(ownerRepository.sumPaidRevenue).mockResolvedValue(0);
  vi.mocked(ownerRepository.countPaidTrips).mockResolvedValue(0);
  vi.mocked(ownerRepository.monthlyRevenue).mockResolvedValue([]);
  vi.mocked(ownerRepository.recentTransactions).mockResolvedValue([]);
  vi.mocked(ownerRepository.perVehicleStats).mockResolvedValue([]);
});

describe("ownerService.getRevenue per-vehicle stats", () => {
  it("maps per-vehicle rows into the response, preserving null rating", async () => {
    vi.mocked(ownerRepository.perVehicleStats).mockResolvedValue([
      { vehicleId: "v-1", title: "Car A", earnings: 500, trips: 3, avgRating: 4.5 },
      { vehicleId: "v-2", title: "Car B", earnings: 0, trips: 0, avgRating: null },
    ]);

    const result = await ownerService.getRevenue("owner-1", 6);

    expect(result.vehicles).toEqual([
      { vehicleId: "v-1", title: "Car A", earnings: 500, trips: 3, avgRating: 4.5 },
      { vehicleId: "v-2", title: "Car B", earnings: 0, trips: 0, avgRating: null },
    ]);
    expect(ownerRepository.perVehicleStats).toHaveBeenCalledWith("owner-1");
  });

  it("returns an empty vehicle list when owner has no cars", async () => {
    const result = await ownerService.getRevenue("owner-1", 6);
    expect(result.vehicles).toEqual([]);
  });
});
