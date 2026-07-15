import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/lib/services/notification.service", () => ({
  notificationService: { safeCreate: vi.fn() },
}));
vi.mock("@/lib/services/email.service", () => ({
  emailService: { sendNotificationEmail: vi.fn() },
}));

import { notificationEvents } from "@/lib/services/notification.events";
import { notificationService } from "@/lib/services/notification.service";

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
