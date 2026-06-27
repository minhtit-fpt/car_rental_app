import { beforeEach, describe, expect, it, vi } from "vitest";
import { NotificationType, type Notification } from "@prisma/client";

vi.mock("@/lib/repositories/notification.repository", () => ({
  notificationRepository: {
    create: vi.fn(),
    findManyByUser: vi.fn(),
    countUnread: vi.fn(),
    findById: vi.fn(),
    markRead: vi.fn(),
    markAllRead: vi.fn(),
  },
}));

import { notificationService } from "@/lib/services/notification.service";
import { notificationRepository } from "@/lib/repositories/notification.repository";
import { AppError } from "@/lib/errors/app-error";

const USER = "user-1";

function makeNotif(overrides: Partial<Notification> = {}): Notification {
  return {
    id: "notif-1",
    userId: USER,
    type: NotificationType.BOOKING,
    title: "Chuyến đi được xác nhận",
    body: "Nội dung",
    payload: null,
    readAt: null,
    createdAt: new Date("2026-06-01T00:00:00Z"),
    ...overrides,
  } as Notification;
}

describe("notificationService.list", () => {
  beforeEach(() => vi.clearAllMocks());

  it("returns items with unread count and pagination", async () => {
    vi.mocked(notificationRepository.findManyByUser).mockResolvedValue({
      items: [makeNotif()],
      total: 1,
    });
    vi.mocked(notificationRepository.countUnread).mockResolvedValue(1);

    const result = await notificationService.list(USER, { page: 1, limit: 20 });

    expect(result.total).toBe(1);
    expect(result.unreadCount).toBe(1);
    expect(result.items[0]?.readAt).toBeNull();
    expect(result.items[0]?.createdAt).toBe("2026-06-01T00:00:00.000Z");
  });
});

describe("notificationService.markRead", () => {
  beforeEach(() => vi.clearAllMocks());

  it("marks read and returns remaining unread count", async () => {
    vi.mocked(notificationRepository.findById).mockResolvedValue(makeNotif());
    vi.mocked(notificationRepository.markRead).mockResolvedValue(1);
    vi.mocked(notificationRepository.countUnread).mockResolvedValue(0);

    const result = await notificationService.markRead(USER, "notif-1");

    expect(notificationRepository.markRead).toHaveBeenCalledWith(
      "notif-1",
      USER,
    );
    expect(result.unreadCount).toBe(0);
  });

  it("throws 404 when notification belongs to another user", async () => {
    vi.mocked(notificationRepository.findById).mockResolvedValue(
      makeNotif({ userId: "other" }),
    );

    await expect(
      notificationService.markRead(USER, "notif-1"),
    ).rejects.toThrow(AppError);
    expect(notificationRepository.markRead).not.toHaveBeenCalled();
  });

  it("throws 404 when notification does not exist", async () => {
    vi.mocked(notificationRepository.findById).mockResolvedValue(null);

    await expect(
      notificationService.markRead(USER, "missing"),
    ).rejects.toThrow(AppError);
  });
});

describe("notificationService.markAllRead", () => {
  beforeEach(() => vi.clearAllMocks());

  it("returns number of updated notifications", async () => {
    vi.mocked(notificationRepository.markAllRead).mockResolvedValue(3);

    const result = await notificationService.markAllRead(USER);

    expect(result.updated).toBe(3);
  });
});

describe("notificationService.notify", () => {
  beforeEach(() => vi.clearAllMocks());

  it("creates a notification with the given fields", async () => {
    vi.mocked(notificationRepository.create).mockResolvedValue(makeNotif());

    await notificationService.notify({
      userId: USER,
      type: NotificationType.BOOKING,
      title: "Yêu cầu đặt xe mới",
      body: "Nội dung",
      payload: { bookingId: "b-1", role: "owner" },
    });

    expect(notificationRepository.create).toHaveBeenCalledWith({
      userId: USER,
      type: NotificationType.BOOKING,
      title: "Yêu cầu đặt xe mới",
      body: "Nội dung",
      payload: { bookingId: "b-1", role: "owner" },
    });
  });

  it("never throws when the repository fails (notifications are side effects)", async () => {
    const spy = vi.spyOn(console, "error").mockImplementation(() => {});
    vi.mocked(notificationRepository.create).mockRejectedValue(
      new Error("db down"),
    );

    await expect(
      notificationService.notify({
        userId: USER,
        type: NotificationType.PAYMENT,
        title: "Thanh toán thành công",
      }),
    ).resolves.toBeUndefined();

    spy.mockRestore();
  });
});
