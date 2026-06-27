import { describe, expect, it } from "vitest";
import {
  applyFactors,
  buildSurgeFactors,
  computeRentalHours,
  DEFAULT_HOLIDAYS,
  type PriceFactor,
} from "@/lib/utils/surge.util";

// Giờ lưu ở UTC; các yếu tố surge đánh giá theo giờ VN (UTC+7).
// Helper: tạo Date từ giờ VN cho test dễ đọc.
function vn(iso: string): Date {
  // iso không kèm offset → coi là giờ VN, trừ 7h ra UTC.
  return new Date(`${iso}+07:00`);
}

describe("computeRentalHours", () => {
  it("rounds partial hours up", () => {
    const start = vn("2026-07-01T10:00:00");
    const end = vn("2026-07-01T11:30:00");
    expect(computeRentalHours(start, end)).toBe(2);
  });

  it("returns a minimum of 1 hour", () => {
    const start = vn("2026-07-01T10:00:00");
    const end = vn("2026-07-01T10:10:00");
    expect(computeRentalHours(start, end)).toBe(1);
  });

  it("computes exact whole hours", () => {
    const start = vn("2026-07-01T10:00:00");
    const end = vn("2026-07-01T13:00:00");
    expect(computeRentalHours(start, end)).toBe(3);
  });
});

describe("buildSurgeFactors — peak hour", () => {
  it("applies an evening peak factor for a 19:00 VN start (Wednesday)", () => {
    // 2026-07-01 là thứ Tư, không lễ.
    const factors = buildSurgeFactors({
      startTime: vn("2026-07-01T19:00:00"),
      hours: 2,
    });
    const peak = factors.find((f) => f.code === "PEAK_HOUR");
    expect(peak).toBeDefined();
    expect(peak?.multiplier).toBeGreaterThan(1);
  });

  it("does not apply a peak factor at 14:00 VN (off-peak)", () => {
    const factors = buildSurgeFactors({
      startTime: vn("2026-07-01T14:00:00"),
      hours: 2,
    });
    expect(factors.find((f) => f.code === "PEAK_HOUR")).toBeUndefined();
  });
});

describe("buildSurgeFactors — weekend", () => {
  it("applies a weekend factor for a Saturday start", () => {
    // 2026-07-04 là thứ Bảy.
    const factors = buildSurgeFactors({
      startTime: vn("2026-07-04T14:00:00"),
      hours: 2,
    });
    const weekend = factors.find((f) => f.code === "WEEKEND");
    expect(weekend).toBeDefined();
    expect(weekend?.multiplier).toBeGreaterThan(1);
  });

  it("does not apply a weekend factor on a weekday", () => {
    const factors = buildSurgeFactors({
      startTime: vn("2026-07-01T14:00:00"),
      hours: 2,
    });
    expect(factors.find((f) => f.code === "WEEKEND")).toBeUndefined();
  });
});

describe("buildSurgeFactors — holiday", () => {
  it("applies a holiday factor on a fixed national holiday (Sep 2)", () => {
    const factors = buildSurgeFactors({
      startTime: vn("2026-09-02T14:00:00"),
      hours: 2,
    });
    const holiday = factors.find((f) => f.code === "HOLIDAY");
    expect(holiday).toBeDefined();
    expect(holiday?.multiplier).toBeGreaterThan(1);
  });

  it("exposes the default holiday set as MM-DD strings", () => {
    expect(DEFAULT_HOLIDAYS.has("09-02")).toBe(true);
    expect(DEFAULT_HOLIDAYS.has("01-01")).toBe(true);
  });
});

describe("buildSurgeFactors — duration discount", () => {
  it("gives a discount (<1) for multi-day rentals", () => {
    const factors = buildSurgeFactors({
      startTime: vn("2026-07-01T14:00:00"),
      hours: 72,
    });
    const discount = factors.find((f) => f.code === "DURATION_DISCOUNT");
    expect(discount).toBeDefined();
    expect(discount?.multiplier).toBeLessThan(1);
  });

  it("applies no discount for short rentals", () => {
    const factors = buildSurgeFactors({
      startTime: vn("2026-07-01T14:00:00"),
      hours: 3,
    });
    expect(
      factors.find((f) => f.code === "DURATION_DISCOUNT"),
    ).toBeUndefined();
  });
});

describe("buildSurgeFactors — demand", () => {
  it("applies a demand factor when a surge multiplier is supplied", () => {
    const factors = buildSurgeFactors({
      startTime: vn("2026-07-01T14:00:00"),
      hours: 2,
      demandMultiplier: 1.25,
    });
    const demand = factors.find((f) => f.code === "DEMAND");
    expect(demand?.multiplier).toBe(1.25);
  });

  it("clamps an extreme demand multiplier into the allowed band", () => {
    const factors = buildSurgeFactors({
      startTime: vn("2026-07-01T14:00:00"),
      hours: 2,
      demandMultiplier: 99,
    });
    const demand = factors.find((f) => f.code === "DEMAND");
    expect(demand?.multiplier).toBeLessThanOrEqual(1.5);
  });

  it("omits the demand factor when the multiplier is neutral (1)", () => {
    const factors = buildSurgeFactors({
      startTime: vn("2026-07-01T14:00:00"),
      hours: 2,
      demandMultiplier: 1,
    });
    expect(factors.find((f) => f.code === "DEMAND")).toBeUndefined();
  });
});

describe("applyFactors", () => {
  it("multiplies the base price by all factor multipliers and rounds", () => {
    const factors: PriceFactor[] = [
      { code: "A", label: "A", multiplier: 1.2 },
      { code: "B", label: "B", multiplier: 1.1 },
    ];
    // 1000 * 1.2 * 1.1 = 1320
    expect(applyFactors(1000, factors)).toBe(1320);
  });

  it("returns the base price unchanged when there are no factors", () => {
    expect(applyFactors(1000, [])).toBe(1000);
  });

  it("rounds fractional results to a whole VND amount", () => {
    const factors: PriceFactor[] = [
      { code: "A", label: "A", multiplier: 1.15 },
    ];
    // 333 * 1.15 = 382.95 → 383
    expect(applyFactors(333, factors)).toBe(383);
  });
});
