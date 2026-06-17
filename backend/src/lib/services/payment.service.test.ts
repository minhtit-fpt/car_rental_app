import { beforeEach, describe, expect, it, vi } from "vitest";
import {
  BookingStatus,
  PaymentMethod,
  PaymentStatus,
  Prisma,
  type Booking,
  type Payment,
} from "@prisma/client";

vi.mock("@/lib/repositories/booking.repository", () => ({
  bookingRepository: { findById: vi.fn() },
}));
vi.mock("@/lib/repositories/payment.repository", () => ({
  paymentRepository: {
    create: vi.fn(),
    findById: vi.fn(),
    findByBookingId: vi.fn(),
    updateStatus: vi.fn(),
  },
}));
vi.mock("@/lib/payments", () => ({
  paymentProvider: { createPayment: vi.fn(), verifyCallback: vi.fn() },
  paymentProviderName: "mock",
}));
vi.mock("@/lib/services/booking.service", () => ({
  bookingService: { confirmAfterPayment: vi.fn() },
}));

import { paymentService } from "@/lib/services/payment.service";
import { bookingRepository } from "@/lib/repositories/booking.repository";
import { paymentRepository } from "@/lib/repositories/payment.repository";
import { paymentProvider } from "@/lib/payments";
import { bookingService } from "@/lib/services/booking.service";
import { AppError } from "@/lib/errors/app-error";

const RENTER = "renter-1";
const BOOKING_ID = "book-1";
const PAYMENT_ID = "pay-1";

function makeBooking(overrides: Partial<Booking> = {}): Booking {
  return {
    id: BOOKING_ID,
    vehicleId: "veh-1",
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

function makePayment(overrides: Partial<Payment> = {}): Payment {
  return {
    id: PAYMENT_ID,
    bookingId: BOOKING_ID,
    method: PaymentMethod.VNPAY,
    status: PaymentStatus.PENDING,
    amount: new Prisma.Decimal(400),
    gatewayRef: "VNPAY-abc",
    paidAt: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  } as Payment;
}

beforeEach(() => vi.clearAllMocks());

describe("paymentService.create", () => {
  it("creates a PENDING VNPAY payment and returns the gateway payUrl", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(makeBooking());
    vi.mocked(paymentRepository.findByBookingId).mockResolvedValue(null);
    vi.mocked(paymentProvider.createPayment).mockResolvedValue({
      payUrl: "https://sandbox/pay?ref=book-1",
      gatewayRef: "VNPAY-xyz",
    });
    vi.mocked(paymentRepository.create).mockResolvedValue(
      makePayment({ gatewayRef: "VNPAY-xyz" }),
    );

    const result = await paymentService.create(RENTER, {
      bookingId: BOOKING_ID,
    });

    expect(paymentRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({
        bookingId: BOOKING_ID,
        method: PaymentMethod.VNPAY,
        amount: 400,
      }),
    );
    expect(result.payUrl).toBe("https://sandbox/pay?ref=book-1");
    expect(result.payment.status).toBe(PaymentStatus.PENDING);
  });

  it("throws 409 when the booking is not awaiting payment", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(
      makeBooking({ status: BookingStatus.CONFIRMED }),
    );
    await expect(
      paymentService.create(RENTER, { bookingId: BOOKING_ID }),
    ).rejects.toMatchObject({ status: 409, code: "PAYMENT_NOT_ALLOWED" });
  });

  it("throws 409 when a paid payment already exists", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(makeBooking());
    vi.mocked(paymentRepository.findByBookingId).mockResolvedValue(
      makePayment({ status: PaymentStatus.PAID }),
    );
    await expect(
      paymentService.create(RENTER, { bookingId: BOOKING_ID }),
    ).rejects.toMatchObject({ status: 409, code: "ALREADY_PAID" });
  });

  it("throws 403 when paying for another renter's booking", async () => {
    vi.mocked(bookingRepository.findById).mockResolvedValue(
      makeBooking({ renterId: "someone-else" }),
    );
    await expect(
      paymentService.create(RENTER, { bookingId: BOOKING_ID }),
    ).rejects.toMatchObject({ status: 403, code: "FORBIDDEN" });
  });
});

describe("paymentService.confirm", () => {
  it("marks the payment PAID and confirms the booking on success", async () => {
    vi.mocked(paymentRepository.findById).mockResolvedValue(makePayment());
    vi.mocked(bookingRepository.findById).mockResolvedValue(makeBooking());
    vi.mocked(paymentProvider.verifyCallback).mockResolvedValue(true);
    vi.mocked(bookingService.confirmAfterPayment).mockResolvedValue({
      status: BookingStatus.CONFIRMED,
    } as never);
    vi.mocked(paymentRepository.updateStatus).mockResolvedValue(
      makePayment({ status: PaymentStatus.PAID, paidAt: new Date() }),
    );

    const result = await paymentService.confirm(RENTER, PAYMENT_ID, {
      success: true,
    });

    expect(bookingService.confirmAfterPayment).toHaveBeenCalledWith(BOOKING_ID);
    expect(paymentRepository.updateStatus).toHaveBeenCalledWith(
      PAYMENT_ID,
      expect.objectContaining({ status: PaymentStatus.PAID }),
    );
    expect(result.payment.status).toBe(PaymentStatus.PAID);
    expect(result.booking).not.toBeNull();
  });

  it("marks the payment FAILED and leaves the booking when the callback fails", async () => {
    vi.mocked(paymentRepository.findById).mockResolvedValue(makePayment());
    vi.mocked(bookingRepository.findById).mockResolvedValue(makeBooking());
    vi.mocked(paymentProvider.verifyCallback).mockResolvedValue(false);
    vi.mocked(paymentRepository.updateStatus).mockResolvedValue(
      makePayment({ status: PaymentStatus.FAILED }),
    );

    const result = await paymentService.confirm(RENTER, PAYMENT_ID, {
      success: false,
    });

    expect(bookingService.confirmAfterPayment).not.toHaveBeenCalled();
    expect(result.payment.status).toBe(PaymentStatus.FAILED);
    expect(result.booking).toBeNull();
  });

  it("does not mark paid when confirming hits a booking conflict", async () => {
    vi.mocked(paymentRepository.findById).mockResolvedValue(makePayment());
    vi.mocked(bookingRepository.findById).mockResolvedValue(makeBooking());
    vi.mocked(paymentProvider.verifyCallback).mockResolvedValue(true);
    vi.mocked(bookingService.confirmAfterPayment).mockRejectedValue(
      new AppError(409, "BOOKING_CONFLICT", "Trùng giờ"),
    );

    await expect(
      paymentService.confirm(RENTER, PAYMENT_ID, { success: true }),
    ).rejects.toMatchObject({ status: 409, code: "BOOKING_CONFLICT" });
    expect(paymentRepository.updateStatus).not.toHaveBeenCalled();
  });

  it("throws 409 when the payment is already paid", async () => {
    vi.mocked(paymentRepository.findById).mockResolvedValue(
      makePayment({ status: PaymentStatus.PAID }),
    );
    vi.mocked(bookingRepository.findById).mockResolvedValue(makeBooking());
    await expect(
      paymentService.confirm(RENTER, PAYMENT_ID, { success: true }),
    ).rejects.toMatchObject({ status: 409, code: "ALREADY_PAID" });
  });
});
