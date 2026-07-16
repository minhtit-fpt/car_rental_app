import { type ChatMessage, type Prisma } from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho Chat (ChatConversation / ConversationParticipant /
// ChatMessage) — CHỈ nơi đây gọi Prisma cho các bảng chat.

const PARTICIPANT_USER_SELECT = {
  select: { id: true, phone: true, email: true },
} satisfies Prisma.UserDefaultArgs;

const CONVERSATION_INCLUDE = {
  participants: { include: { user: PARTICIPANT_USER_SELECT } },
  messages: { orderBy: { sentAt: "desc" }, take: 1 },
} satisfies Prisma.ChatConversationInclude;

export type ConversationWithDetails = Prisma.ChatConversationGetPayload<{
  include: typeof CONVERSATION_INCLUDE;
}>;

export interface ListMessagesParams {
  conversationId: string;
  page: number;
  limit: number;
}

export const chatRepository = {
  // Các cuộc hội thoại người dùng tham gia, mới hoạt động trước.
  async findConversationsForUser(
    userId: string,
  ): Promise<ConversationWithDetails[]> {
    return prisma.chatConversation.findMany({
      where: { participants: { some: { userId } } },
      include: CONVERSATION_INCLUDE,
      orderBy: [{ lastMessageAt: "desc" }, { createdAt: "desc" }],
    });
  },

  findConversationById(id: string): Promise<ConversationWithDetails | null> {
    return prisma.chatConversation.findUnique({
      where: { id },
      include: CONVERSATION_INCLUDE,
    });
  },

  findConversationByBooking(
    bookingId: string,
  ): Promise<ConversationWithDetails | null> {
    return prisma.chatConversation.findUnique({
      where: { bookingId },
      include: CONVERSATION_INCLUDE,
    });
  },

  // Tìm cuộc 1-1 (không gắn booking) giữa 2 người dùng, nếu có.
  async findDirectConversation(
    userIdA: string,
    userIdB: string,
  ): Promise<ConversationWithDetails | null> {
    const candidates = await prisma.chatConversation.findMany({
      where: {
        bookingId: null,
        AND: [
          { participants: { some: { userId: userIdA } } },
          { participants: { some: { userId: userIdB } } },
        ],
      },
      include: CONVERSATION_INCLUDE,
    });
    return candidates.find((c) => c.participants.length === 2) ?? null;
  },

  // Tạo hội thoại với danh sách participant cho trước.
  createConversation(
    userIds: string[],
    bookingId?: string,
  ): Promise<ConversationWithDetails> {
    return prisma.chatConversation.create({
      data: {
        bookingId,
        participants: { create: userIds.map((userId) => ({ userId })) },
      },
      include: CONVERSATION_INCLUDE,
    });
  },

  isParticipant(conversationId: string, userId: string): Promise<unknown> {
    return prisma.conversationParticipant.findUnique({
      where: { conversationId_userId: { conversationId, userId } },
    });
  },

  async findMessages(
    p: ListMessagesParams,
  ): Promise<{ items: ChatMessage[]; total: number }> {
    const where = { conversationId: p.conversationId };
    const [items, total] = await Promise.all([
      prisma.chatMessage.findMany({
        where,
        orderBy: { sentAt: "desc" },
        skip: (p.page - 1) * p.limit,
        take: p.limit,
      }),
      prisma.chatMessage.count({ where }),
    ]);
    return { items, total };
  },

  // Gửi tin nhắn + cập nhật lastMessageAt của hội thoại (atomic).
  async createMessage(
    conversationId: string,
    senderId: string,
    body: string,
  ): Promise<ChatMessage> {
    const [message] = await prisma.$transaction([
      prisma.chatMessage.create({
        data: { conversationId, senderId, body },
      }),
      prisma.chatConversation.update({
        where: { id: conversationId },
        data: { lastMessageAt: new Date() },
      }),
    ]);
    return message;
  },

  // Số tin chưa đọc cho NHIỀU hội thoại trong 1 query (tránh N+1).
  async countUnreadBatch(
    userId: string,
    entries: Array<{ conversationId: string; since: Date | null }>,
  ): Promise<Map<string, number>> {
    if (entries.length === 0) return new Map();
    const grouped = await prisma.chatMessage.groupBy({
      by: ["conversationId"],
      where: {
        senderId: { not: userId },
        OR: entries.map((e) => ({
          conversationId: e.conversationId,
          ...(e.since ? { sentAt: { gt: e.since } } : {}),
        })),
      },
      _count: { _all: true },
    });
    return new Map(grouped.map((g) => [g.conversationId, g._count._all]));
  },

  // Số tin nhắn chưa đọc của người dùng trong 1 hội thoại.
  countUnread(
    conversationId: string,
    userId: string,
    since: Date | null,
  ): Promise<number> {
    return prisma.chatMessage.count({
      where: {
        conversationId,
        senderId: { not: userId },
        ...(since ? { sentAt: { gt: since } } : {}),
      },
    });
  },

  markRead(conversationId: string, userId: string): Promise<unknown> {
    return prisma.conversationParticipant.update({
      where: { conversationId_userId: { conversationId, userId } },
      data: { lastReadAt: new Date() },
    });
  },
};
