import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/lib/repositories/community.repository", () => ({
  communityRepository: {
    findMany: vi.fn(),
    create: vi.fn(),
    findById: vi.fn(),
    incrementLikes: vi.fn(),
  },
}));

import { communityService } from "@/lib/services/community.service";
import { communityRepository } from "@/lib/repositories/community.repository";
import { AppError } from "@/lib/errors/app-error";

const USER = "user-1";

function makeStory(overrides: Record<string, unknown> = {}) {
  return {
    id: "story-1",
    userId: USER,
    bookingId: null,
    content: "Chuyến đi tuyệt vời",
    images: [],
    likes: 5,
    createdAt: new Date("2026-06-01T00:00:00Z"),
    updatedAt: new Date("2026-06-01T00:00:00Z"),
    user: { id: USER, phone: "0901234567", email: "thanh@example.com" },
    ...overrides,
  };
}

describe("communityService.list", () => {
  beforeEach(() => vi.clearAllMocks());

  it("maps stories with author display name from email", async () => {
    vi.mocked(communityRepository.findMany).mockResolvedValue({
      items: [makeStory() as never],
      total: 1,
    });

    const result = await communityService.list({ page: 1, limit: 20 });

    expect(result.total).toBe(1);
    expect(result.items[0]?.authorName).toBe("thanh");
    expect(result.items[0]?.likes).toBe(5);
  });

  it("falls back to masked phone when email is null", async () => {
    vi.mocked(communityRepository.findMany).mockResolvedValue({
      items: [
        makeStory({
          user: { id: USER, phone: "0901234567", email: null },
        }) as never,
      ],
      total: 1,
    });

    const result = await communityService.list({ page: 1, limit: 20 });

    expect(result.items[0]?.authorName).toBe("***4567");
  });
});

describe("communityService.create", () => {
  beforeEach(() => vi.clearAllMocks());

  it("creates a story for the author", async () => {
    vi.mocked(communityRepository.create).mockResolvedValue(
      makeStory({ content: "Mới" }) as never,
    );

    const result = await communityService.create(USER, {
      content: "Mới",
      images: [],
    });

    expect(communityRepository.create).toHaveBeenCalledWith({
      userId: USER,
      content: "Mới",
      images: [],
      bookingId: undefined,
    });
    expect(result.authorId).toBe(USER);
  });
});

describe("communityService.like", () => {
  beforeEach(() => vi.clearAllMocks());

  it("increments likes when story exists", async () => {
    vi.mocked(communityRepository.findById).mockResolvedValue(
      makeStory() as never,
    );
    vi.mocked(communityRepository.incrementLikes).mockResolvedValue(
      makeStory({ likes: 6 }) as never,
    );

    const result = await communityService.like("story-1");

    expect(result.likes).toBe(6);
  });

  it("throws 404 when story missing", async () => {
    vi.mocked(communityRepository.findById).mockResolvedValue(null);

    await expect(communityService.like("missing")).rejects.toThrow(AppError);
    expect(communityRepository.incrementLikes).not.toHaveBeenCalled();
  });
});
