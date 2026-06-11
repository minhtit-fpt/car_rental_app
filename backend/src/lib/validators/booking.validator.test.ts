import { describe, expect, it } from "vitest";
import {
  createBookingSchema,
  listBookingsQuerySchema,
} from "@/lib/validators/booking.validator";

const VEHICLE_ID = "11111111-1111-1111-1111-111111111111";

describe("createBookingSchema", () => {
  it("accepts a valid booking and defaults deliveryRequested", () => {
    const parsed = createBookingSchema.parse({
      vehicleId: VEHICLE_ID,
      startTime: "2026-07-01T08:00:00Z",
      endTime: "2026-07-01T12:00:00Z",
    });
    expect(parsed.deliveryRequested).toBe(false);
  });

  it("rejects when endTime is not after startTime", () => {
    expect(() =>
      createBookingSchema.parse({
        vehicleId: VEHICLE_ID,
        startTime: "2026-07-01T12:00:00Z",
        endTime: "2026-07-01T08:00:00Z",
      }),
    ).toThrow();
  });

  it("rejects a non-uuid vehicleId", () => {
    expect(() =>
      createBookingSchema.parse({
        vehicleId: "nope",
        startTime: "2026-07-01T08:00:00Z",
        endTime: "2026-07-01T12:00:00Z",
      }),
    ).toThrow();
  });
});

describe("listBookingsQuerySchema", () => {
  it("defaults pagination and accepts an optional status", () => {
    expect(listBookingsQuerySchema.parse({})).toMatchObject({
      page: 1,
      limit: 20,
    });
    expect(
      listBookingsQuerySchema.parse({ status: "CONFIRMED" }).status,
    ).toBe("CONFIRMED");
  });

  it("rejects an invalid status", () => {
    expect(() => listBookingsQuerySchema.parse({ status: "NOPE" })).toThrow();
  });
});
