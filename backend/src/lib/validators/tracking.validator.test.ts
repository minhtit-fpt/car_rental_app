import { describe, expect, it } from "vitest";
import {
  ingestLocationSchema,
  latestQuerySchema,
} from "@/lib/validators/tracking.validator";

describe("ingestLocationSchema", () => {
  it("accepts valid coords with optional speed", () => {
    const parsed = ingestLocationSchema.parse({ lat: 21.02, lng: 105.83 });
    expect(parsed.lat).toBeCloseTo(21.02);
    expect(parsed.speedKmh).toBeUndefined();
  });

  it("rejects out-of-range latitude", () => {
    expect(() => ingestLocationSchema.parse({ lat: 200, lng: 0 })).toThrow();
  });

  it("rejects negative speed", () => {
    expect(() =>
      ingestLocationSchema.parse({ lat: 0, lng: 0, speedKmh: -5 }),
    ).toThrow();
  });
});

describe("latestQuerySchema", () => {
  it("coerces trail string and defaults to 0", () => {
    expect(latestQuerySchema.parse({ trail: "20" }).trail).toBe(20);
    expect(latestQuerySchema.parse({}).trail).toBe(0);
  });

  it("rejects trail above cap", () => {
    expect(() => latestQuerySchema.parse({ trail: "500" })).toThrow();
  });
});
