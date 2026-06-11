import { beforeEach, describe, expect, it, vi } from "vitest";
import {
  BookingStatus,
  Prisma,
  VehicleType,
  type Booking,
  type Vehicle,
} from "@prisma/client";

vi.mock("@/lib/repositories/booking.repository", () => ({
  bookingRepository: {
    create: vi.fn(),
    findById: vi.fn(),
    findManyByRenter: vi.fn(),
    hasActiveOverlap: vi.fn(),
    updateStatus: vi.fn(),
  },
}));

vi.mock("@/lib/repositories/vehicle.repository", () => ({
  vehicleRepository: {
    findById: vi.fn(),
  },
}));

import { bookingService } from "@/lib/services/booking.service";
import { bookingRepository } from "@/lib/repositories/booking.repository";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";

const RENTER = "renter-1";
const VEHICLE_ID = "veh-1";

function makeVehicle(overrides: Partial<Vehicle> = {}): Vehicle {
  return {
    id: VEHICLE_ID,
    ownerId: "owner-1",
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

function makeBooking(overrides: Partial<Booking> = {}): Booking {
  return {
    id: "book-1",
    vehicleId: VEHICLE_ID,
    renterId: RENTER,
    status: BookingStatus.PENDING_PAYMENT,
    startTime: new Date("2026-07-01T08:00:00Z"),
    endTime: new Date("2026-07-01T12:00:00Z"),
    totalPrice: new Prisma.Decimal(400),
    deliveryRequested: false,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  } as Booking;
}

const VALID_INPUT = {
  vehicleId: VEHICLE_ID,
  startTime: "2026-07-01T08:00:00Z",
  endTime: "2026-07-01T12:00:00Z",
  deliveryRequested: false,
};

beforeEach(() => vi.clearAllMocks());

describe("bookingService.create", () => {
  it("computes total = hours * pricePerHour and stores PENDING_PAYMENT", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(makeVehicle());
    vi.mocked(bookingRepository.hasActiveOverlap).mockResolvedValue(false);
    vi.mocked(bookingRepository.create).mockResolvedValue(makeBooking());

    const result = await bookingService.create(RENTER, VALID_INPUT);

    // 4 giờ * 100 = 400
    expect(bookingRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({ totalPrice: 400, renterId: RENTER }),
    );
    expect(result.status).toBe(BookingStatus.PENDING_PAYMENT);
    expect(result.totalPrice).toBe(400);
  });

  it("throws 409 when the vehicle has an overlapping active booking", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(makeVehicle());
    vi.mocked(bookingRepository.hasActiveOverlap).mockResolvedValue(true);

    await expect(bookingService.create(RENTER, VALID_INPUT)).rejects.toMatchObject(
      { status: 409, code: "BOOKING_CONFLICT" },
    );
    expect(bookingRepository.create).not.toHaveBeenCalled();
  });

  it("throws 404 when the vehicle is missing", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(null);
    await expect(bookingService.create(RENTER, VALID_INPUT)).rejects.toMatchObject(
      { status: 404, code: "VEHICLE_NOT_FOUND" },
    );
  });

  it("throws 409 when the vehicle is unavailable", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(
      makeVehicle({ isAvailable: false }),
    );
    await expect(bookingService.create(RENTER, VALID_INPUT)).rejects.toMatchObject(
      { status: 409, code: "VEHICLE_UNAVAILABLE" },
    );
  });

  it("throws 400 when delivery is requested but not supported", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(
      makeVehicle({ deliveryAvailable: false }),
    );
    await expect(
      bookingService.create(RENTER, { ...VALID_INPUT, deliveryRequested: true }),
    ).rejects.toMatchObject({ status: 400, code: "DELIVERY_UNAVAILABLE" });
  });
});

describe("bookingService.cancel", () => {
  it("cancels a PENDING_PAYMENT booking owned by the renter", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(makeBooking());
    vi.mocked(bookingRepository.updateStatus).mockResolvedValue(
      makeBooking({ status: BookingStatus.CANCELLED }),
    );
    const result = await bookingService.cancel(RENTER, "book-1");
    expect(result.status).toBe(BookingStatus.CANCELLED);
  });

  it("throws 403 when cancelling another renter's booking", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(
      makeBooking({ renterId: "someone-else" }),
    );
    await expect(bookingService.cancel(RENTER, "book-1")).rejects.toMatchObject({
      status: 403,
      code: "FORBIDDEN",
    });
  });

  it("throws 409 when the booking is already COMPLETED", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(
      makeBooking({ status: BookingStatus.COMPLETED }),
    );
    await expect(bookingService.cancel(RENTER, "book-1")).rejects.toMatchObject({
      status: 409,
      code: "BOOKING_NOT_CANCELLABLE",
    });
    expect(bookingRepository.updateStatus).not.toHaveBeenCalled();
  });
});
