import { describe, expect, it } from "vitest";
import {
  createReviewSchema,
  listReviewsQuerySchema,
} from "@/lib/validators/review.validator";

const BOOKING_ID = "11111111-1111-1111-1111-111111111111";

describe("createReviewSchema", () => {
  it("accepts a valid review", () => {
    const parsed = createReviewSchema.parse({
      bookingId: BOOKING_ID,
      rating: 5,
      comment: "Xe sạch, chủ thân thiện",
    });
    expect(parsed.rating).toBe(5);
  });

  it("allows omitting the comment", () => {
    expect(
      createReviewSchema.parse({ bookingId: BOOKING_ID, rating: 4 }).comment,
    ).toBeUndefined();
  });

  it("rejects a rating out of 1..5", () => {
    expect(() =>
      createReviewSchema.parse({ bookingId: BOOKING_ID, rating: 6 }),
    ).toThrow();
    expect(() =>
      createReviewSchema.parse({ bookingId: BOOKING_ID, rating: 0 }),
    ).toThrow();
  });

  it("rejects a non-integer rating", () => {
    expect(() =>
      createReviewSchema.parse({ bookingId: BOOKING_ID, rating: 4.5 }),
    ).toThrow();
  });
});

describe("listReviewsQuerySchema", () => {
  it("defaults pagination", () => {
    expect(listReviewsQuerySchema.parse({})).toMatchObject({
      page: 1,
      limit: 20,
    });
  });
});
