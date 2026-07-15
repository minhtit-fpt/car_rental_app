import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import {
  BookingStatus,
  Prisma,
  VehicleType,
  type Booking,
  type Vehicle,
} from "@prisma/client";

vi.mock("@/lib/services/notification.service", () => ({
  notificationService: { notify: vi.fn() },
}));

vi.mock("@/lib/repositories/booking.repository", () => ({
  bookingRepository: {
    create: vi.fn(),
    findById: vi.fn(),
    findManyByRenter: vi.fn(),
    findManyByOwner: vi.fn(),
    findByIdForOwner: vi.fn(),
    findByVehicle: vi.fn(),
    hasActiveOverlap: vi.fn(),
    findOverduePendingPayment: vi.fn(),
    findOverdueAwaitingOwner: vi.fn(),
    updateStatus: vi.fn(),
  },
}));

vi.mock("@/lib/services/refund.service", () => ({
  refundService: { refundBookingPayment: vi.fn() },
}));

vi.mock("@/lib/repositories/vehicle.repository", () => ({
  vehicleRepository: {
    findById: vi.fn(),
  },
}));

vi.mock("@/lib/services/notification.events", () => ({
  notificationEvents: {
    bookingCreated: vi.fn(),
    bookingApproved: vi.fn(),
    bookingRejected: vi.fn(),
    paymentAwaitingOwner: vi.fn(),
    paymentExpired: vi.fn(),
    bookingCancelled: vi.fn(),
  },
}));

import { bookingService } from "@/lib/services/booking.service";
import { bookingRepository } from "@/lib/repositories/booking.repository";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";
import { notificationEvents } from "@/lib/services/notification.events";
import { refundService } from "@/lib/services/refund.service";

const RENTER = "renter-1";
const VEHICLE_ID = "veh-1";

function makeVehicle(overrides: Partial<Vehicle> = {}): Vehicle {
  return {
    id: VEHICLE_ID,
    ownerId: "owner-1",
    type: VehicleType.CAR,
    title: "VF8",
    pricePerDay: new Prisma.Decimal(100),
    isElectric: false,
    isAvailable: true,
    deliveryAvailable: false,
    approvalStatus: "APPROVED",
    rejectionReason: null,
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
    totalPrice: new Prisma.Decimal(100),
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
  it("computes total = days * pricePerDay and stores PENDING_PAYMENT", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(makeVehicle());
    vi.mocked(bookingRepository.hasActiveOverlap).mockResolvedValue(false);
    vi.mocked(bookingRepository.create).mockResolvedValue(makeBooking());

    const result = await bookingService.create(RENTER, VALID_INPUT);

    // Thuê trong ngày (08:00–12:00) → 1 ngày * 100 = 100
    expect(bookingRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({ totalPrice: 100, renterId: RENTER }),
    );
    expect(result.status).toBe(BookingStatus.PENDING_PAYMENT);
    expect(result.totalPrice).toBe(100);
    // Pay-first: chỉ báo renter lúc tạo đơn, KHÔNG kèm ownerId (owner báo sau khi trả tiền).
    expect(notificationEvents.bookingCreated).toHaveBeenCalledWith(
      expect.objectContaining({ renterId: RENTER }),
    );
    expect(notificationEvents.bookingCreated).not.toHaveBeenCalledWith(
      expect.objectContaining({ ownerId: expect.anything() }),
    );
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

  it("throws 409 when the vehicle is not approved", async () => {
    vi.mocked(vehicleRepository.findById).mockResolvedValue(
      makeVehicle({ approvalStatus: "PENDING" }),
    );
    await expect(
      bookingService.create(RENTER, VALID_INPUT),
    ).rejects.toMatchObject({ status: 409, code: "VEHICLE_NOT_APPROVED" });
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
  it("cancels a PENDING_PAYMENT booking owned by the renter and notifies the owner", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(makeBooking());
    vi.mocked(bookingRepository.updateStatus).mockResolvedValue(
      makeBooking({ status: BookingStatus.CANCELLED }),
    );
    vi.mocked(vehicleRepository.findById).mockResolvedValue(makeVehicle());
    const result = await bookingService.cancel(RENTER, "book-1");
    expect(result.status).toBe(BookingStatus.CANCELLED);
    expect(notificationEvents.bookingCancelled).toHaveBeenCalledWith(
      expect.objectContaining({ bookingId: "book-1", ownerId: "owner-1" }),
    );
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

const OWNER = "owner-1";

function makeOwnerBooking(overrides: Partial<Booking> = {}) {
  const b = makeBooking(overrides);
  return {
    ...b,
    vehicle: { id: VEHICLE_ID, title: "VF8", type: VehicleType.CAR, ownerId: OWNER },
    renter: { id: RENTER, phone: "0900000000", email: null },
  };
}

describe("bookingService.listForOwner", () => {
  it("maps owner bookings with nested vehicle + renter", async () => {
    vi.mocked(bookingRepository.findManyByOwner).mockResolvedValue({
      items: [makeOwnerBooking()] as never,
      total: 1,
    });
    const result = await bookingService.listForOwner({
      ownerId: OWNER,
      page: 1,
      limit: 20,
    });
    expect(result.total).toBe(1);
    expect(result.items[0].vehicle.title).toBe("VF8");
    expect(result.items[0].renter.phone).toBe("0900000000");
  });
});

describe("bookingService.approve", () => {
  it("confirms an AWAITING_OWNER booking on the owner's vehicle", async () => {
    vi.mocked(bookingRepository.findByIdForOwner)
      .mockResolvedValueOnce(
        makeOwnerBooking({ status: BookingStatus.AWAITING_OWNER }) as never,
      )
      .mockResolvedValueOnce(
        makeOwnerBooking({ status: BookingStatus.CONFIRMED }) as never,
      );
    vi.mocked(bookingRepository.hasActiveOverlap).mockResolvedValue(false);
    vi.mocked(bookingRepository.updateStatus).mockResolvedValue(makeBooking());

    const result = await bookingService.approve(OWNER, "book-1");

    expect(bookingRepository.updateStatus).toHaveBeenCalledWith(
      "book-1",
      BookingStatus.CONFIRMED,
    );
    expect(result.status).toBe(BookingStatus.CONFIRMED);
  });

  it("throws 403 when the vehicle belongs to another owner", async () => {
    vi.mocked(bookingRepository.findByIdForOwner).mockResolvedValue(
      makeOwnerBooking() as never,
    );
    await expect(
      bookingService.approve("other-owner", "book-1"),
    ).rejects.toMatchObject({ status: 403, code: "FORBIDDEN" });
    expect(bookingRepository.updateStatus).not.toHaveBeenCalled();
  });

  it("throws 409 when the booking is not AWAITING_OWNER", async () => {
    vi.mocked(bookingRepository.findByIdForOwner).mockResolvedValue(
      makeOwnerBooking({ status: BookingStatus.CONFIRMED }) as never,
    );
    await expect(bookingService.approve(OWNER, "book-1")).rejects.toMatchObject({
      status: 409,
      code: "BOOKING_NOT_APPROVABLE",
    });
  });

  it("throws 409 BOOKING_CONFLICT when the slot is already taken", async () => {
    vi.mocked(bookingRepository.findByIdForOwner).mockResolvedValue(
      makeOwnerBooking({ status: BookingStatus.AWAITING_OWNER }) as never,
    );
    vi.mocked(bookingRepository.hasActiveOverlap).mockResolvedValue(true);
    await expect(bookingService.approve(OWNER, "book-1")).rejects.toMatchObject({
      status: 409,
      code: "BOOKING_CONFLICT",
    });
    expect(bookingRepository.updateStatus).not.toHaveBeenCalled();
  });
});

describe("bookingService.reject", () => {
  it("cancels an AWAITING_OWNER booking and auto-refunds", async () => {
    vi.mocked(bookingRepository.findByIdForOwner)
      .mockResolvedValueOnce(
        makeOwnerBooking({ status: BookingStatus.AWAITING_OWNER }) as never,
      )
      .mockResolvedValueOnce(
        makeOwnerBooking({ status: BookingStatus.CANCELLED }) as never,
      );
    vi.mocked(refundService.refundBookingPayment).mockResolvedValue({
      bookingId: "book-1",
      renterId: RENTER,
      status: "REFUNDED",
      amount: 100,
    } as never);
    vi.mocked(bookingRepository.updateStatus).mockResolvedValue(makeBooking());

    const result = await bookingService.reject(OWNER, "book-1");

    expect(refundService.refundBookingPayment).toHaveBeenCalledWith(
      expect.objectContaining({ bookingId: "book-1", actorId: null }),
    );
    expect(bookingRepository.updateStatus).toHaveBeenCalledWith(
      "book-1",
      BookingStatus.CANCELLED,
    );
    expect(result.status).toBe(BookingStatus.CANCELLED);
  });

  it("throws 409 when the booking is not AWAITING_OWNER", async () => {
    vi.mocked(bookingRepository.findByIdForOwner).mockResolvedValue(
      makeOwnerBooking({ status: BookingStatus.IN_PROGRESS }) as never,
    );
    await expect(bookingService.reject(OWNER, "book-1")).rejects.toMatchObject({
      status: 409,
      code: "BOOKING_NOT_REJECTABLE",
    });
  });
});

describe("bookingService.expireOverduePayments", () => {
  const ORIGINAL_HOURS = process.env.PAYMENT_REMINDER_HOURS;

  afterEach(() => {
    if (ORIGINAL_HOURS === undefined) delete process.env.PAYMENT_REMINDER_HOURS;
    else process.env.PAYMENT_REMINDER_HOURS = ORIGINAL_HOURS;
  });

  it("cancels each overdue booking and notifies its renter", async () => {
    vi.mocked(bookingRepository.findOverduePendingPayment).mockResolvedValue([
      makeBooking({ id: "book-1", renterId: "r1" }),
      makeBooking({ id: "book-2", renterId: "r2" }),
    ]);
    vi.mocked(bookingRepository.updateStatus).mockResolvedValue(
      makeBooking({ status: BookingStatus.CANCELLED }),
    );

    const result = await bookingService.expireOverduePayments();

    expect(result.expired).toBe(2);
    expect(bookingRepository.updateStatus).toHaveBeenNthCalledWith(
      1,
      "book-1",
      BookingStatus.CANCELLED,
    );
    expect(bookingRepository.updateStatus).toHaveBeenNthCalledWith(
      2,
      "book-2",
      BookingStatus.CANCELLED,
    );
    expect(notificationEvents.paymentExpired).toHaveBeenCalledWith({
      bookingId: "book-1",
      renterId: "r1",
    });
    expect(notificationEvents.paymentExpired).toHaveBeenCalledWith({
      bookingId: "book-2",
      renterId: "r2",
    });
  });

  it("uses PAYMENT_REMINDER_HOURS to compute the cutoff", async () => {
    process.env.PAYMENT_REMINDER_HOURS = "3";
    vi.mocked(bookingRepository.findOverduePendingPayment).mockResolvedValue([]);
    const now = Date.now();

    await bookingService.expireOverduePayments();

    const before = vi.mocked(bookingRepository.findOverduePendingPayment).mock
      .calls[0][0] as Date;
    const elapsedHours = (now - before.getTime()) / 3_600_000;
    expect(elapsedHours).toBeCloseTo(3, 1);
  });

  it("keeps going when one booking fails and counts only the cancelled ones", async () => {
    vi.mocked(bookingRepository.findOverduePendingPayment).mockResolvedValue([
      makeBooking({ id: "book-1", renterId: "r1" }),
      makeBooking({ id: "book-2", renterId: "r2" }),
    ]);
    vi.mocked(bookingRepository.updateStatus)
      .mockRejectedValueOnce(new Error("db down"))
      .mockResolvedValueOnce(makeBooking({ status: BookingStatus.CANCELLED }));
    const errorSpy = vi.spyOn(console, "error").mockImplementation(() => {});

    const result = await bookingService.expireOverduePayments();

    expect(result.expired).toBe(1);
    expect(notificationEvents.paymentExpired).toHaveBeenCalledTimes(1);
    expect(notificationEvents.paymentExpired).toHaveBeenCalledWith({
      bookingId: "book-2",
      renterId: "r2",
    });
    errorSpy.mockRestore();
  });

  it("returns zero when there are no overdue bookings", async () => {
    vi.mocked(bookingRepository.findOverduePendingPayment).mockResolvedValue([]);

    const result = await bookingService.expireOverduePayments();

    expect(result.expired).toBe(0);
    expect(bookingRepository.updateStatus).not.toHaveBeenCalled();
    expect(notificationEvents.paymentExpired).not.toHaveBeenCalled();
  });
});

describe("bookingService.expireOverdueOwnerApprovals", () => {
  it("refunds, cancels and notifies each overdue awaiting-owner booking", async () => {
    vi.mocked(bookingRepository.findOverdueAwaitingOwner).mockResolvedValue([
      makeBooking({ id: "book-1", renterId: "r1" }),
    ]);
    vi.mocked(refundService.refundBookingPayment).mockResolvedValue({
      bookingId: "book-1",
      renterId: "r1",
      status: "REFUNDED",
      amount: 100,
    } as never);
    vi.mocked(bookingRepository.updateStatus).mockResolvedValue(
      makeBooking({ status: BookingStatus.CANCELLED }),
    );

    const result = await bookingService.expireOverdueOwnerApprovals();

    expect(result.expired).toBe(1);
    expect(refundService.refundBookingPayment).toHaveBeenCalledWith(
      expect.objectContaining({ bookingId: "book-1", actorId: null }),
    );
    expect(bookingRepository.updateStatus).toHaveBeenCalledWith(
      "book-1",
      BookingStatus.CANCELLED,
    );
  });

  it("skips a booking whose refund fails and does not cancel it", async () => {
    vi.mocked(bookingRepository.findOverdueAwaitingOwner).mockResolvedValue([
      makeBooking({ id: "book-1", renterId: "r1" }),
    ]);
    vi.mocked(refundService.refundBookingPayment).mockRejectedValue(
      new Error("no payment"),
    );
    const errorSpy = vi.spyOn(console, "error").mockImplementation(() => {});

    const result = await bookingService.expireOverdueOwnerApprovals();

    expect(result.expired).toBe(0);
    expect(bookingRepository.updateStatus).not.toHaveBeenCalled();
    errorSpy.mockRestore();
  });
});
