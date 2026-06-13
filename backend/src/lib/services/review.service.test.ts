import { beforeEach, describe, expect, it, vi } from "vitest";
import {
  BookingStatus,
  Prisma,
  VehicleType,
  type Booking,
  type Review,
  type Vehicle,
} from "@prisma/client";

vi.mock("@/lib/repositories/booking.repository", () => ({
  bookingRepository: { findById: vi.fn() },
}));
vi.mock("@/lib/repositories/vehicle.repository", () => ({
  vehicleRepository: { findById: vi.fn() },
}));
vi.mock("@/lib/repositories/review.repository", () => ({
  reviewRepository: {
    create: vi.fn(),
    findManyByTarget: vi.fn(),
    summaryForTarget: vi.fn(),
  },
}));

import { reviewService } from "@/lib/services/review.service";
import { bookingRepository } from "@/lib/repositories/booking.repository";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";
import { reviewRepository } from "@/lib/repositories/review.repository";

const RENTER = "renter-1";
const OWNER = "owner-1";
const BOOKING_ID = "book-1";

function makeBooking(overrides: Partial<Booking> = {}): Booking {
  return {
    id: BOOKING_ID,
    vehicleId: "veh-1",
    renterId: RENTER,
    status: BookingStatus.CONFIRMED,
    startTime: new Date(),
    endTime: new Date(),
    totalPrice: new Prisma.Decimal(400),
    deliveryRequested: false,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  } as Booking;
}

function makeVehicle(overrides: Partial<Vehicle> = {}): Vehicle {
  return {
    id: "veh-1",
    ownerId: OWNER,
    type: VehicleType.CAR,
    title: "VF8",
    pricePerHour: new Prisma.Decimal(100),
    isElectric: false,
    isAvailable: true,
    deliveryAvailable: false,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  } as Vehicle;
}

function makeReview(overrides: Partial<Review> = {}): Review {
  return {
    id: "rev-1",
    bookingId: BOOKING_ID,
    reviewerId: RENTER,
    targetId: OWNER,
    rating: 5,
    comment: "Tốt",
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  } as Review;
}

const INPUT = { bookingId: BOOKING_ID, rating: 5, comment: "Tốt" };

beforeEach(() => vi.clearAllMocks());

describe("reviewService.create", () => {
  it("targets the vehicle owner when the renter reviews", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(makeBooking());
    vi.mocked(vehicleRepository.findById).mockResolvedValue(makeVehicle());
    vi.mocked(reviewRepository.create).mockResolvedValue(makeReview());

    const result = await reviewService.create(RENTER, INPUT);

    expect(reviewRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({ reviewerId: RENTER, targetId: OWNER }),
    );
    expect(result.targetId).toBe(OWNER);
  });

  it("targets the renter when the owner reviews", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(makeBooking());
    vi.mocked(vehicleRepository.findById).mockResolvedValue(makeVehicle());
    vi.mocked(reviewRepository.create).mockResolvedValue(
      makeReview({ reviewerId: OWNER, targetId: RENTER }),
    );

    const result = await reviewService.create(OWNER, INPUT);

    expect(reviewRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({ reviewerId: OWNER, targetId: RENTER }),
    );
    expect(result.targetId).toBe(RENTER);
  });

  it("throws 403 when the reviewer is not part of the booking", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(makeBooking());
    vi.mocked(vehicleRepository.findById).mockResolvedValue(makeVehicle());
    await expect(
      reviewService.create("stranger", INPUT),
    ).rejects.toMatchObject({ status: 403, code: "FORBIDDEN" });
  });

  it("throws 409 when the booking is still awaiting payment", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(
      makeBooking({ status: BookingStatus.PENDING_PAYMENT }),
    );
    await expect(reviewService.create(RENTER, INPUT)).rejects.toMatchObject({
      status: 409,
      code: "REVIEW_NOT_ALLOWED",
    });
  });

  it("throws 404 when the booking is missing", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(null);
    await expect(reviewService.create(RENTER, INPUT)).rejects.toMatchObject({
      status: 404,
      code: "BOOKING_NOT_FOUND",
    });
  });

  it("maps a unique-violation to 409 ALREADY_REVIEWED", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(makeBooking());
    vi.mocked(vehicleRepository.findById).mockResolvedValue(makeVehicle());
    vi.mocked(reviewRepository.create).mockRejectedValue(
      new Prisma.PrismaClientKnownRequestError("dup", {
        code: "P2002",
        clientVersion: "5",
      }),
    );
    await expect(reviewService.create(RENTER, INPUT)).rejects.toMatchObject({
      status: 409,
      code: "ALREADY_REVIEWED",
    });
  });
});

describe("reviewService.listForTarget", () => {
  it("returns items with the average rating", async () => {
    vi.mocked(reviewRepository.findManyByTarget).mockResolvedValue({
      items: [makeReview(), makeReview({ id: "rev-2", rating: 3 })],
      total: 2,
    });
    vi.mocked(reviewRepository.summaryForTarget).mockResolvedValue({
      average: 4,
      count: 2,
    });

    const result = await reviewService.listForTarget(OWNER, {
      page: 1,
      limit: 20,
    });

    expect(result.total).toBe(2);
    expect(result.average).toBe(4);
    expect(result.items).toHaveLength(2);
  });
});
