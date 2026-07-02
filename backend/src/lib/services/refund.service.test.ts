import { beforeEach, describe, expect, it, vi } from "vitest";
import { Prisma } from "@prisma/client";

vi.mock("@/lib/repositories/admin.repository", () => ({
  adminRepository: {
    findBookingForRefund: vi.fn(),
    refundPayment: vi.fn(),
  },
}));

import { refundService } from "@/lib/services/refund.service";
import { adminRepository } from "@/lib/repositories/admin.repository";

function booking(status: string, amount = 100) {
  return {
    id: "b-1",
    renterId: "r-1",
    payment: { status, amount: new Prisma.Decimal(amount) },
  } as never;
}

beforeEach(() => {
  vi.clearAllMocks();
  vi.mocked(adminRepository.refundPayment).mockResolvedValue({
    status: "REFUNDED",
  } as never);
});

describe("refundService.refundBookingPayment", () => {
  it("refunds the full paid amount by default (system actor)", async () => {
    vi.mocked(adminRepository.findBookingForRefund).mockResolvedValue(
      booking("PAID", 250),
    );

    const result = await refundService.refundBookingPayment({
      bookingId: "b-1",
      actorId: null,
      reason: "owner rejected",
    });

    expect(result).toEqual({
      bookingId: "b-1",
      renterId: "r-1",
      status: "REFUNDED",
      amount: 250,
    });
    expect(adminRepository.refundPayment).toHaveBeenCalledWith(
      "b-1",
      250,
      null,
      "owner rejected",
    );
  });

  it("rejects a partial amount greater than the paid amount", async () => {
    vi.mocked(adminRepository.findBookingForRefund).mockResolvedValue(
      booking("PAID", 100),
    );
    await expect(
      refundService.refundBookingPayment({
        bookingId: "b-1",
        actorId: "admin-1",
        reason: "x",
        amount: 200,
      }),
    ).rejects.toMatchObject({ status: 400, code: "INVALID_REFUND_AMOUNT" });
  });

  it("throws when the payment is not PAID", async () => {
    vi.mocked(adminRepository.findBookingForRefund).mockResolvedValue(
      booking("PENDING"),
    );
    await expect(
      refundService.refundBookingPayment({
        bookingId: "b-1",
        actorId: null,
        reason: "x",
      }),
    ).rejects.toMatchObject({ status: 409, code: "PAYMENT_NOT_REFUNDABLE" });
  });

  it("throws 404 when the booking does not exist", async () => {
    vi.mocked(adminRepository.findBookingForRefund).mockResolvedValue(null);
    await expect(
      refundService.refundBookingPayment({
        bookingId: "nope",
        actorId: null,
        reason: "x",
      }),
    ).rejects.toMatchObject({ status: 404, code: "BOOKING_NOT_FOUND" });
  });
});
