import {
  type Notification,
  type NotificationType,
  type Prisma,
} from "@prisma/client";
import { AppError } from "@/lib/errors/app-error";
import { notificationRepository } from "@/lib/repositories/notification.repository";
import type { ListNotificationsQuery } from "@/lib/validators/notification.validator";

export interface NotifyInput {
  userId: string;
  type: NotificationType;
  title: string;
  body?: string | null;
  payload?: Prisma.InputJsonValue;
}

export interface PublicNotification {
  id: string;
  type: NotificationType;
  title: string;
  body: string | null;
  payload: unknown;
  readAt: string | null;
  createdAt: string;
}

export interface NotificationListResult {
  items: PublicNotification[];
  total: number;
  unreadCount: number;
  page: number;
  limit: number;
}

function toPublic(n: Notification): PublicNotification {
  return {
    id: n.id,
    type: n.type,
    title: n.title,
    body: n.body,
    payload: n.payload,
    readAt: n.readAt ? n.readAt.toISOString() : null,
    createdAt: n.createdAt.toISOString(),
  };
}

export const notificationService = {
  // Tạo thông báo cho người dùng. Cố ý KHÔNG bao giờ ném lỗi: thông báo là tác
  // dụng phụ, không được phép làm hỏng luồng chính (đặt xe, thanh toán, KYC...).
  async notify(input: NotifyInput): Promise<void> {
    try {
      await notificationRepository.create(input);
    } catch (error) {
      console.error("[notification] tạo thông báo thất bại", error);
    }
  },

  // Tạo thông báo và TRẢ VỀ bản ghi (dạng public). Ném lỗi nếu repo thất bại —
  // dùng khi caller cần biết kết quả.
  async create(input: NotifyInput): Promise<PublicNotification> {
    return toPublic(await notificationRepository.create(input));
  },

  // Như create nhưng KHÔNG bao giờ ném: trả null nếu thất bại. Dùng cho thông báo
  // theo sự kiện (notification.events) — lỗi noti không được làm hỏng luồng chính.
  async safeCreate(input: NotifyInput): Promise<PublicNotification | null> {
    try {
      return await this.create(input);
    } catch (error) {
      console.error("[notification] tạo thông báo thất bại", error);
      return null;
    }
  },

  async list(
    userId: string,
    query: ListNotificationsQuery,
  ): Promise<NotificationListResult> {
    const [{ items, total }, unreadCount] = await Promise.all([
      notificationRepository.findManyByUser({ userId, ...query }),
      notificationRepository.countUnread(userId),
    ]);
    return {
      items: items.map(toPublic),
      total,
      unreadCount,
      page: query.page,
      limit: query.limit,
    };
  },

  // Đánh dấu đã đọc; ném 404 nếu không thuộc người dùng. Trả số chưa đọc còn lại.
  async markRead(userId: string, id: string): Promise<{ unreadCount: number }> {
    const existing = await notificationRepository.findById(id);
    if (!existing || existing.userId !== userId) {
      throw new AppError(404, "NOTIFICATION_NOT_FOUND", "Không tìm thấy thông báo");
    }
    await notificationRepository.markRead(id, userId);
    return { unreadCount: await notificationRepository.countUnread(userId) };
  },

  async markAllRead(userId: string): Promise<{ updated: number }> {
    return { updated: await notificationRepository.markAllRead(userId) };
  },
};
