import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/lib/repositories/chat.repository", () => ({
  chatRepository: {
    findConversationsForUser: vi.fn(),
    findConversationById: vi.fn(),
    findConversationByBooking: vi.fn(),
    findDirectConversation: vi.fn(),
    createConversation: vi.fn(),
    findMessages: vi.fn(),
    createMessage: vi.fn(),
    countUnread: vi.fn(),
    markRead: vi.fn(),
  },
}));
vi.mock("@/lib/repositories/booking.repository", () => ({
  bookingRepository: { findById: vi.fn() },
}));
vi.mock("@/lib/repositories/vehicle.repository", () => ({
  vehicleRepository: { findById: vi.fn() },
}));

import { chatService } from "@/lib/services/chat.service";
import { chatRepository } from "@/lib/repositories/chat.repository";
import { bookingRepository } from "@/lib/repositories/booking.repository";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";
import { AppError } from "@/lib/errors/app-error";

const ME = "user-me";
const OTHER = "user-other";

function makeConversation(overrides: Record<string, unknown> = {}) {
  return {
    id: "conv-1",
    bookingId: null,
    lastMessageAt: new Date("2026-06-01T10:00:00Z"),
    createdAt: new Date("2026-06-01T09:00:00Z"),
    participants: [
      {
        userId: ME,
        lastReadAt: null,
        user: { id: ME, phone: "0900000001", email: "me@example.com" },
      },
      {
        userId: OTHER,
        lastReadAt: null,
        user: { id: OTHER, phone: "0900000002", email: null },
      },
    ],
    messages: [{ id: "m1", body: "Xin chào", sentAt: new Date() }],
    ...overrides,
  };
}

describe("chatService.listConversations", () => {
  beforeEach(() => vi.clearAllMocks());

  it("maps partner, last message and unread count", async () => {
    vi.mocked(chatRepository.findConversationsForUser).mockResolvedValue([
      makeConversation() as never,
    ]);
    vi.mocked(chatRepository.countUnread).mockResolvedValue(3);

    const result = await chatService.listConversations(ME);

    expect(result).toHaveLength(1);
    expect(result[0]?.partner?.id).toBe(OTHER);
    expect(result[0]?.partner?.name).toBe("***0002");
    expect(result[0]?.lastMessage).toBe("Xin chào");
    expect(result[0]?.unreadCount).toBe(3);
  });
});

describe("chatService.createOrGetConversation", () => {
  beforeEach(() => vi.clearAllMocks());

  it("returns existing direct conversation when present", async () => {
    vi.mocked(chatRepository.findDirectConversation).mockResolvedValue(
      makeConversation() as never,
    );
    vi.mocked(chatRepository.countUnread).mockResolvedValue(0);

    const result = await chatService.createOrGetConversation(ME, {
      participantId: OTHER,
    });

    expect(chatRepository.createConversation).not.toHaveBeenCalled();
    expect(result.id).toBe("conv-1");
  });

  it("creates a new direct conversation when none exists", async () => {
    vi.mocked(chatRepository.findDirectConversation).mockResolvedValue(null);
    vi.mocked(chatRepository.createConversation).mockResolvedValue(
      makeConversation() as never,
    );
    vi.mocked(chatRepository.countUnread).mockResolvedValue(0);

    await chatService.createOrGetConversation(ME, { participantId: OTHER });

    expect(chatRepository.createConversation).toHaveBeenCalledWith([ME, OTHER]);
  });

  it("rejects messaging yourself", async () => {
    await expect(
      chatService.createOrGetConversation(ME, { participantId: ME }),
    ).rejects.toThrow(AppError);
  });

  it("creates a booking conversation with renter and owner", async () => {
    vi.mocked(chatRepository.findConversationByBooking).mockResolvedValue(null);
    vi.mocked(bookingRepository.findById).mockResolvedValue({
      id: "book-1",
      vehicleId: "veh-1",
      renterId: ME,
    } as never);
    vi.mocked(vehicleRepository.findById).mockResolvedValue({
      id: "veh-1",
      ownerId: OTHER,
    } as never);
    vi.mocked(chatRepository.createConversation).mockResolvedValue(
      makeConversation({ bookingId: "book-1" }) as never,
    );
    vi.mocked(chatRepository.countUnread).mockResolvedValue(0);

    await chatService.createOrGetConversation(ME, { bookingId: "book-1" });

    expect(chatRepository.createConversation).toHaveBeenCalledWith(
      [ME, OTHER],
      "book-1",
    );
  });
});

describe("chatService.sendMessage", () => {
  beforeEach(() => vi.clearAllMocks());

  it("rejects when user is not a participant", async () => {
    vi.mocked(chatRepository.findConversationById).mockResolvedValue(
      makeConversation({
        participants: [
          {
            userId: OTHER,
            lastReadAt: null,
            user: { id: OTHER, phone: "0900000002", email: null },
          },
        ],
      }) as never,
    );

    await expect(
      chatService.sendMessage(ME, "conv-1", { body: "Hi" }),
    ).rejects.toThrow(AppError);
    expect(chatRepository.createMessage).not.toHaveBeenCalled();
  });

  it("sends when participant", async () => {
    vi.mocked(chatRepository.findConversationById).mockResolvedValue(
      makeConversation() as never,
    );
    vi.mocked(chatRepository.createMessage).mockResolvedValue({
      id: "m2",
      conversationId: "conv-1",
      senderId: ME,
      body: "Hi",
      sentAt: new Date("2026-06-01T11:00:00Z"),
      readAt: null,
    } as never);

    const result = await chatService.sendMessage(ME, "conv-1", { body: "Hi" });

    expect(result.body).toBe("Hi");
    expect(result.senderId).toBe(ME);
  });
});
