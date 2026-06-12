import { describe, expect, it } from "vitest";
import {
  confirmPaymentSchema,
  createPaymentSchema,
} from "@/lib/validators/payment.validator";

const BOOKING_ID = "11111111-1111-1111-1111-111111111111";

describe("createPaymentSchema", () => {
  it("accepts a valid bookingId", () => {
    expect(createPaymentSchema.parse({ bookingId: BOOKING_ID })).toEqual({
      bookingId: BOOKING_ID,
    });
  });

  it("rejects a non-uuid bookingId", () => {
    expect(() => createPaymentSchema.parse({ bookingId: "nope" })).toThrow();
  });
});

describe("confirmPaymentSchema", () => {
  it("defaults success to true", () => {
    expect(confirmPaymentSchema.parse({}).success).toBe(true);
  });

  it("accepts an explicit success flag", () => {
    expect(confirmPaymentSchema.parse({ success: false }).success).toBe(false);
  });
});
