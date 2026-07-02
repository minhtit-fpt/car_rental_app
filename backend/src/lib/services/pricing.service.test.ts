import { beforeEach, describe, expect, it, vi } from "vitest";
import { Prisma, VehicleType, type Vehicle } from "@prisma/client";

vi.mock("@/lib/repositories/vehicle.repository", () => ({
  vehicleRepository: {
    findById: vi.fn(),
  },
}));

import { pricingService } from "@/lib/services/pricing.service";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";

function vn(iso: string): Date {
  return new Date(`${iso}+07:00`);
}

function makeVehicle(overrides: Partial<Vehicle> = {}): Vehicle {
  return {
    id: "veh-1",
    ownerId: "owner-1",
    type: VehicleType.CAR,
    title: "Vinfast VF8",
    pricePerDay: new Prisma.Decimal(100_000),
    isElectric: true,
    isAvailable: true,
    deliveryAvailable: false,
    createdAt: new Date("2026-06-10T00:00:00Z"),
    updatedAt: new Date("2026-06-10T00:00:00Z"),
    ...overrides,
  } as Vehicle;
}

beforeEach(() => vi.clearAllMocks());

describe("pricingService.quote", () => {
  it("returns the base price when no surge factors apply", () => {
    // Thứ Tư, thuê trong ngày → 1 ngày, không lễ/cuối tuần/giảm dài.
    const quote = pricingService.quote({
      pricePerDay: 100_000,
      startTime: vn("2026-07-01T14:00:00"),
      endTime: vn("2026-07-01T16:00:00"),
    });
    expect(quote.basePrice).toBe(100_000);
    expect(quote.days).toBe(1);
    expect(quote.factors).toHaveLength(0);
    expect(quote.finalPrice).toBe(100_000);
    expect(quote.currency).toBe("VND");
  });

  it("applies a weekend factor and reflects it in finalPrice", () => {
    // Thứ Bảy → cuối tuần 1.2, 1 ngày.
    const quote = pricingService.quote({
      pricePerDay: 100_000,
      startTime: vn("2026-07-04T14:00:00"),
      endTime: vn("2026-07-04T16:00:00"),
    });
    expect(quote.factors.map((f) => f.code)).toContain("WEEKEND");
    // base 100k * 1.2 = 120k
    expect(quote.finalPrice).toBe(120_000);
  });

  it("applies a holiday factor on a national holiday", () => {
    // 2026-09-02 Quốc khánh → 1.3.
    const quote = pricingService.quote({
      pricePerDay: 100_000,
      startTime: vn("2026-09-02T14:00:00"),
      endTime: vn("2026-09-02T16:00:00"),
    });
    expect(quote.factors.map((f) => f.code)).toContain("HOLIDAY");
    expect(quote.finalPrice).toBe(130_000);
  });

  it("applies a duration discount for multi-day rentals", () => {
    // 3 ngày → base 300k, giảm giá thuê dài (<300k).
    const start = vn("2026-07-01T14:00:00");
    const end = new Date(start.getTime() + 72 * 3_600_000);
    const quote = pricingService.quote({
      pricePerDay: 100_000,
      startTime: start,
      endTime: end,
    });
    expect(quote.days).toBe(3);
    expect(quote.basePrice).toBe(300_000);
    expect(quote.factors.map((f) => f.code)).toContain("DURATION_DISCOUNT");
    expect(quote.finalPrice).toBeLessThan(quote.basePrice);
  });
});

describe("pricingService.quoteForVehicle", () => {
  it("loads the vehicle price from the DB and returns a quote", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(makeVehicle());
    const quote = await pricingService.quoteForVehicle({
      vehicleId: "veh-1",
      startTime: vn("2026-07-01T14:00:00"),
      endTime: vn("2026-07-01T16:00:00"),
    });
    expect(quote.basePricePerDay).toBe(100_000);
    expect(quote.basePrice).toBe(100_000);
  });

  it("throws 404 when the vehicle does not exist", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(null);
    await expect(
      pricingService.quoteForVehicle({
        vehicleId: "nope",
        startTime: vn("2026-07-01T14:00:00"),
        endTime: vn("2026-07-01T16:00:00"),
      }),
    ).rejects.toMatchObject({ status: 404, code: "VEHICLE_NOT_FOUND" });
  });
});
