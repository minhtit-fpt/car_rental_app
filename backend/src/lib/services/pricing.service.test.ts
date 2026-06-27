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
    pricePerHour: new Prisma.Decimal(100_000),
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
    // Thứ Tư 14:00, thuê 2 giờ → không lễ/cuối tuần/cao điểm/giảm dài.
    const quote = pricingService.quote({
      pricePerHour: 100_000,
      startTime: vn("2026-07-01T14:00:00"),
      endTime: vn("2026-07-01T16:00:00"),
    });
    expect(quote.basePrice).toBe(200_000);
    expect(quote.hours).toBe(2);
    expect(quote.factors).toHaveLength(0);
    expect(quote.finalPrice).toBe(200_000);
    expect(quote.currency).toBe("VND");
  });

  it("applies a peak-hour factor and reflects it in finalPrice", () => {
    const quote = pricingService.quote({
      pricePerHour: 100_000,
      startTime: vn("2026-07-01T19:00:00"),
      endTime: vn("2026-07-01T21:00:00"),
    });
    expect(quote.factors.map((f) => f.code)).toContain("PEAK_HOUR");
    // base 200k * 1.15 = 230k
    expect(quote.finalPrice).toBe(230_000);
  });

  it("stacks weekend and peak factors multiplicatively", () => {
    // Thứ Bảy 19:00 → cuối tuần (1.2) + cao điểm (1.15).
    const quote = pricingService.quote({
      pricePerHour: 100_000,
      startTime: vn("2026-07-04T19:00:00"),
      endTime: vn("2026-07-04T21:00:00"),
    });
    const codes = quote.factors.map((f) => f.code);
    expect(codes).toContain("WEEKEND");
    expect(codes).toContain("PEAK_HOUR");
    // 200k * 1.2 * 1.15 = 276k
    expect(quote.finalPrice).toBe(276_000);
  });

  it("applies a duration discount for multi-day rentals", () => {
    const start = vn("2026-07-01T14:00:00");
    const end = new Date(start.getTime() + 72 * 3_600_000);
    const quote = pricingService.quote({
      pricePerHour: 100_000,
      startTime: start,
      endTime: end,
    });
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
    expect(quote.basePricePerHour).toBe(100_000);
    expect(quote.basePrice).toBe(200_000);
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
