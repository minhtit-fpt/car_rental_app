import { describe, expect, it } from "vitest";
import {
  createVehicleSchema,
  listVehiclesQuerySchema,
  nearbyQuerySchema,
  updateVehicleSchema,
} from "@/lib/validators/vehicle.validator";

describe("listVehiclesQuerySchema", () => {
  it("applies defaults and parses query strings", () => {
    const parsed = listVehiclesQuerySchema.parse({});
    expect(parsed).toMatchObject({ page: 1, limit: 20 });
  });

  it("coerces filters from strings", () => {
    const parsed = listVehiclesQuerySchema.parse({
      type: "CAR",
      isElectric: "true",
      minPrice: "10",
      maxPrice: "50",
      page: "2",
    });
    expect(parsed.isElectric).toBe(true);
    expect(parsed.minPrice).toBe(10);
    expect(parsed.page).toBe(2);
  });

  it("treats isElectric=false as false (no coerce footgun)", () => {
    expect(listVehiclesQuerySchema.parse({ isElectric: "false" }).isElectric)
      .toBe(false);
  });
});

describe("nearbyQuerySchema", () => {
  it("requires lat/lng and defaults radius", () => {
    const parsed = nearbyQuerySchema.parse({ lat: "10.77", lng: "106.7" });
    expect(parsed.lat).toBeCloseTo(10.77);
    expect(parsed.radius).toBe(5000);
  });

  it("rejects out-of-range latitude", () => {
    expect(() => nearbyQuerySchema.parse({ lat: "200", lng: "0" })).toThrow();
  });
});

describe("createVehicleSchema", () => {
  it("accepts a valid payload with defaults", () => {
    const parsed = createVehicleSchema.parse({
      type: "CAR",
      title: "Vinfast VF8",
      pricePerDay: 120,
      lat: 10.77,
      lng: 106.7,
    });
    expect(parsed.isElectric).toBe(false);
    expect(parsed.isAvailable).toBe(true);
  });

  it("rejects a non-positive price", () => {
    expect(() =>
      createVehicleSchema.parse({
        type: "CAR",
        title: "X",
        pricePerDay: 0,
        lat: 0,
        lng: 0,
      }),
    ).toThrow();
  });
});

describe("updateVehicleSchema", () => {
  it("rejects an empty update", () => {
    expect(() => updateVehicleSchema.parse({})).toThrow();
  });

  it("rejects lat without lng", () => {
    expect(() => updateVehicleSchema.parse({ lat: 10 })).toThrow();
  });

  it("accepts a partial update", () => {
    expect(updateVehicleSchema.parse({ isAvailable: false })).toEqual({
      isAvailable: false,
    });
  });
});
