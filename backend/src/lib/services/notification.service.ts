import { type Notification, type NotificationType } from "@prisma/client";
import { AppError } from "@/lib/errors/app-error";
import { notificationRepository } from "@/lib/repositories/notification.repository";
import type { ListNotificationsQuery } from "@/lib/validators/notification.validator";

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
