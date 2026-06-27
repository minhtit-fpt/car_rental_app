import {
  type Notification,
  type NotificationType,
  type Prisma,
} from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho Notification — CHỈ nơi đây gọi Prisma cho bảng Notification.

export interface ListNotificationsParams {
  userId: string;
  page: number;
  limit: number;
}

export interface CreateNotificationParams {
  userId: string;
  type: NotificationType;
  title: string;
  body?: string | null;
  payload?: Prisma.InputJsonValue;
}

export const notificationRepository = {
  create(p: CreateNotificationParams): Promise<Notification> {
    return prisma.notification.create({
      data: {
        userId: p.userId,
        type: p.type,
        title: p.title,
        body: p.body ?? null,
        payload: p.payload,
      },
    });
  },

  async findManyByUser(
    p: ListNotificationsParams,
  ): Promise<{ items: Notification[]; total: number }> {
    const where: Prisma.NotificationWhereInput = { userId: p.userId };
    const [items, total] = await Promise.all([
      prisma.notification.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip: (p.page - 1) * p.limit,
        take: p.limit,
      }),
      prisma.notification.count({ where }),
    ]);
    return { items, total };
  },

  countUnread(userId: string): Promise<number> {
    return prisma.notification.count({ where: { userId, readAt: null } });
  },

  findById(id: string): Promise<Notification | null> {
    return prisma.notification.findUnique({ where: { id } });
  },

  // Đánh dấu đã đọc 1 thông báo của đúng chủ sở hữu; trả số bản ghi cập nhật.
  async markRead(id: string, userId: string): Promise<number> {
    const result = await prisma.notification.updateMany({
      where: { id, userId, readAt: null },
      data: { readAt: new Date() },
    });
    return result.count;
  },

  async markAllRead(userId: string): Promise<number> {
    const result = await prisma.notification.updateMany({
      where: { userId, readAt: null },
      data: { readAt: new Date() },
    });
    return result.count;
  },
};
