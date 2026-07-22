import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/lib/services/notification.service", () => ({
  notificationService: { safeCreate: vi.fn() },
}));
vi.mock("@/lib/services/email.service", () => ({
  emailService: { sendNotificationEmail: vi.fn(), sendBookingEmail: vi.fn() },
}));

import { notificationEvents } from "@/lib/services/notification.events";
import { notificationService } from "@/lib/services/notification.service";
import { emailService } from "@/lib/services/email.service";

const EMAIL_DETAILS = {
  bookingId: "b-1",
  vehicleTitle: "VinFast VF8",
  startTime: new Date("2026-07-20T09:00:00Z"),
  endTime: new Date("2026-07-22T09:00:00Z"),
  totalPrice: 1_500_000,
};

// Payload gửi cho owner phải kèm `role: 'owner'` để FE điều hướng đúng màn.
function ownerCall(userId: string) {
  return vi
    .mocked(notificationService.safeCreate)
    .mock.calls.map((c) => c[0])
    .find((n) => n.userId === userId);
}

beforeEach(() => vi.clearAllMocks());

describe("notificationEvents owner payloads carry role", () => {
  it("bookingCreated notifies only the renter, not the owner", async () => {
    await notificationEvents.bookingCreated({
      bookingId: "b-1",
      renterId: "r-1",
    });
    // Pay-first: owner không được báo lúc tạo đơn (chỉ sau thanh toán).
    expect(ownerCall("o-1")).toBeUndefined();
    expect(notificationService.safeCreate).toHaveBeenCalledTimes(1);
    // Renter notification stays role-less (routes to /trips).
    expect(ownerCall("r-1")?.payload).toEqual({ bookingId: "b-1" });
  });

  it("paymentAwaitingOwner tags owner notification with role", async () => {
    await notificationEvents.paymentAwaitingOwner({
      bookingId: "b-1",
      renterId: "r-1",
      ownerId: "o-1",
    });
    expect(ownerCall("o-1")?.payload).toEqual({
      bookingId: "b-1",
      role: "owner",
    });
  });

  it("bookingCancelled tags owner notification with role", async () => {
    await notificationEvents.bookingCancelled({
      bookingId: "b-1",
      ownerId: "o-1",
    });
    expect(ownerCall("o-1")?.payload).toEqual({
      bookingId: "b-1",
      role: "owner",
    });
  });
});

describe("notificationEvents transactional emails", () => {
  it("paymentAwaitingOwner emails both renter and owner with booking details", async () => {
    await notificationEvents.paymentAwaitingOwner({
      bookingId: "b-1",
      renterId: "r-1",
      ownerId: "o-1",
      renterEmail: "renter@x.vn",
      ownerEmail: "owner@x.vn",
      emailDetails: EMAIL_DETAILS,
    });
    expect(emailService.sendBookingEmail).toHaveBeenCalledTimes(2);
    expect(emailService.sendBookingEmail).toHaveBeenCalledWith(
      "renter@x.vn",
      expect.stringContaining("Thanh toán thành công"),
      expect.any(String),
      EMAIL_DETAILS,
    );
    expect(emailService.sendBookingEmail).toHaveBeenCalledWith(
      "owner@x.vn",
      expect.stringContaining("Khách đã thanh toán"),
      expect.any(String),
      EMAIL_DETAILS,
    );
  });

  it("skips emails when address or details are missing", async () => {
    await notificationEvents.paymentAwaitingOwner({
      bookingId: "b-1",
      renterId: "r-1",
      ownerId: "o-1",
      renterEmail: "renter@x.vn", // có địa chỉ nhưng thiếu details → bỏ qua
    });
    expect(emailService.sendBookingEmail).not.toHaveBeenCalled();
  });

  it("bookingApproved notifies and emails the renter", async () => {
    await notificationEvents.bookingApproved({
      bookingId: "b-1",
      renterId: "r-1",
      vehicleTitle: "VinFast VF8",
      renterEmail: "renter@x.vn",
      emailDetails: EMAIL_DETAILS,
    });
    expect(ownerCall("r-1")?.body).toContain("VinFast VF8");
    expect(emailService.sendBookingEmail).toHaveBeenCalledWith(
      "renter@x.vn",
      expect.stringContaining("xác nhận"),
      expect.stringContaining("VinFast VF8"),
      EMAIL_DETAILS,
    );
  });

  it("bookingRejected emails the renter with refund details", async () => {
    const details = { ...EMAIL_DETAILS, refundAmount: 1_500_000 };
    await notificationEvents.bookingRejected({
      bookingId: "b-1",
      renterId: "r-1",
      vehicleTitle: "VinFast VF8",
      renterEmail: "renter@x.vn",
      emailDetails: details,
    });
    expect(emailService.sendBookingEmail).toHaveBeenCalledWith(
      "renter@x.vn",
      expect.stringContaining("hoàn tiền"),
      expect.any(String),
      details,
    );
  });

  it("bookingCancelled with refund emails owner and renter, skips owner when null", async () => {
    const details = { ...EMAIL_DETAILS, refundAmount: 1_500_000 };
    await notificationEvents.bookingCancelled({
      bookingId: "b-1",
      ownerId: "o-1",
      ownerEmail: "owner@x.vn",
      renterEmail: "renter@x.vn",
      refunded: true,
      emailDetails: details,
    });
    expect(emailService.sendBookingEmail).toHaveBeenCalledTimes(2);

    vi.clearAllMocks();
    // Renter tự huỷ xe của mình → không noti/email owner, vẫn email hoàn tiền.
    await notificationEvents.bookingCancelled({
      bookingId: "b-1",
      ownerId: null,
      renterEmail: "renter@x.vn",
      refunded: true,
      emailDetails: details,
    });
    expect(notificationService.safeCreate).not.toHaveBeenCalled();
    expect(emailService.sendBookingEmail).toHaveBeenCalledTimes(1);
    expect(emailService.sendBookingEmail).toHaveBeenCalledWith(
      "renter@x.vn",
      expect.stringContaining("hoàn tiền"),
      expect.any(String),
      details,
    );
  });

  it("ownerApprovalExpired notifies and emails the renter about the refund", async () => {
    await notificationEvents.ownerApprovalExpired({
      bookingId: "b-1",
      renterId: "r-1",
      renterEmail: "renter@x.vn",
      emailDetails: EMAIL_DETAILS,
    });
    expect(ownerCall("r-1")?.title).toContain("chủ xe không xác nhận");
    expect(emailService.sendBookingEmail).toHaveBeenCalledWith(
      "renter@x.vn",
      expect.stringContaining("hoàn tiền"),
      expect.any(String),
      EMAIL_DETAILS,
    );
  });
});
