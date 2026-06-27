import { type ChatMessage } from "@prisma/client";
import { AppError } from "@/lib/errors/app-error";
import { bookingRepository } from "@/lib/repositories/booking.repository";
import {
  chatRepository,
  type ConversationWithDetails,
} from "@/lib/repositories/chat.repository";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";
import { notificationService } from "@/lib/services/notification.service";
import type {
  CreateConversationInput,
  ListMessagesQuery,
  SendMessageInput,
} from "@/lib/validators/chat.validator";

export interface ChatParticipant {
  id: string;
  name: string;
}

export interface PublicConversation {
  id: string;
  bookingId: string | null;
  partner: ChatParticipant | null;
  lastMessage: string | null;
  lastMessageAt: string | null;
  unreadCount: number;
}

export interface PublicMessage {
  id: string;
  conversationId: string;
  senderId: string;
  body: string;
  sentAt: string;
  readAt: string | null;
}

export interface MessageListResult {
  items: PublicMessage[];
  total: number;
  page: number;
  limit: number;
}

function displayName(user: { phone: string; email: string | null }): string {
  if (user.email) return user.email.split("@")[0] ?? user.email;
  return user.phone.length > 4 ? `***${user.phone.slice(-4)}` : user.phone;
}

function toMessage(m: ChatMessage): PublicMessage {
  return {
    id: m.id,
    conversationId: m.conversationId,
    senderId: m.senderId,
    body: m.body,
    sentAt: m.sentAt.toISOString(),
    readAt: m.readAt ? m.readAt.toISOString() : null,
  };
}

async function toPublicConversation(
  c: ConversationWithDetails,
  userId: string,
): Promise<PublicConversation> {
  const me = c.participants.find((p) => p.userId === userId);
  const other = c.participants.find((p) => p.userId !== userId);
  const last = c.messages[0];
  const unreadCount = await chatRepository.countUnread(
    c.id,
    userId,
    me?.lastReadAt ?? null,
  );
  return {
    id: c.id,
    bookingId: c.bookingId,
    partner: other
      ? { id: other.userId, name: displayName(other.user) }
      : null,
    lastMessage: last ? last.body : null,
    lastMessageAt: c.lastMessageAt ? c.lastMessageAt.toISOString() : null,
    unreadCount,
  };
}

async function ensureParticipant(
  conversationId: string,
  userId: string,
): Promise<ConversationWithDetails> {
  const conversation = await chatRepository.findConversationById(conversationId);
  if (!conversation) {
    throw new AppError(404, "CONVERSATION_NOT_FOUND", "Không tìm thấy hội thoại");
  }
  if (!conversation.participants.some((p) => p.userId === userId)) {
    throw new AppError(403, "FORBIDDEN", "Bạn không thuộc hội thoại này");
  }
  return conversation;
}

export const chatService = {
  async listConversations(userId: string): Promise<PublicConversation[]> {
    const conversations = await chatRepository.findConversationsForUser(userId);
    return Promise.all(
      conversations.map((c) => toPublicConversation(c, userId)),
    );
  },

  // Tạo mới hoặc lấy lại hội thoại theo booking, hoặc 1-1 với người dùng khác.
  async createOrGetConversation(
    userId: string,
    input: CreateConversationInput,
  ): Promise<PublicConversation> {
    if (input.bookingId) {
      const existing = await chatRepository.findConversationByBooking(
        input.bookingId,
      );
      if (existing) {
        if (!existing.participants.some((p) => p.userId === userId)) {
          throw new AppError(403, "FORBIDDEN", "Bạn không thuộc hội thoại này");
        }
        return toPublicConversation(existing, userId);
      }

      const booking = await bookingRepository.findById(input.bookingId);
      if (!booking) {
        throw new AppError(404, "BOOKING_NOT_FOUND", "Không tìm thấy đơn đặt");
      }
      const vehicle = await vehicleRepository.findById(booking.vehicleId);
      if (!vehicle) {
        throw new AppError(404, "VEHICLE_NOT_FOUND", "Không tìm thấy xe");
      }
      if (booking.renterId !== userId && vehicle.ownerId !== userId) {
        throw new AppError(403, "FORBIDDEN", "Bạn không thuộc đơn đặt này");
      }
      const participants = [booking.renterId, vehicle.ownerId];
      const created = await chatRepository.createConversation(
        Array.from(new Set(participants)),
        input.bookingId,
      );
      return toPublicConversation(created, userId);
    }

    const partnerId = input.participantId!;
    if (partnerId === userId) {
      throw new AppError(
        400,
        "INVALID_PARTICIPANT",
        "Không thể tự nhắn cho chính mình",
      );
    }
    const existing = await chatRepository.findDirectConversation(
      userId,
      partnerId,
    );
    if (existing) return toPublicConversation(existing, userId);

    const created = await chatRepository.createConversation([userId, partnerId]);
    return toPublicConversation(created, userId);
  },

  async listMessages(
    userId: string,
    conversationId: string,
    query: ListMessagesQuery,
  ): Promise<MessageListResult> {
    await ensureParticipant(conversationId, userId);
    const { items, total } = await chatRepository.findMessages({
      conversationId,
      ...query,
    });
    // Mở hội thoại = đã đọc tới hiện tại.
    await chatRepository.markRead(conversationId, userId);
    return {
      items: items.map(toMessage),
      total,
      page: query.page,
      limit: query.limit,
    };
  },

  async sendMessage(
    userId: string,
    conversationId: string,
    input: SendMessageInput,
  ): Promise<PublicMessage> {
    const conversation = await ensureParticipant(conversationId, userId);
    const message = await chatRepository.createMessage(
      conversationId,
      userId,
      input.body,
    );

    // Báo cho (các) thành viên còn lại trong hội thoại có tin nhắn mới.
    const recipients = conversation.participants
      .map((p) => p.userId)
      .filter((id) => id !== userId);
    await Promise.all(
      recipients.map((recipientId) =>
        notificationService.notify({
          userId: recipientId,
          type: "CHAT",
          title: "Tin nhắn mới",
          body: input.body.length > 80 ? `${input.body.slice(0, 80)}…` : input.body,
          payload: { conversationId },
        }),
      ),
    );

    return toMessage(message);
  },
};
