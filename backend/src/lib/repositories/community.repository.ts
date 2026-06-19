import { type Prisma } from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho TripStory (community feed) — CHỈ nơi đây gọi Prisma.

// Kèm thông tin tác giả tối thiểu để hiển thị (User không có trường tên).
const STORY_INCLUDE = {
  user: { select: { id: true, phone: true, email: true } },
} satisfies Prisma.TripStoryInclude;

export type StoryWithAuthor = Prisma.TripStoryGetPayload<{
  include: typeof STORY_INCLUDE;
}>;

export interface ListStoriesParams {
  page: number;
  limit: number;
}

export interface CreateStoryData {
  userId: string;
  content: string;
  images: string[];
  bookingId?: string;
}

export const communityRepository = {
  async findMany(
    p: ListStoriesParams,
  ): Promise<{ items: StoryWithAuthor[]; total: number }> {
    const [items, total] = await Promise.all([
      prisma.tripStory.findMany({
        include: STORY_INCLUDE,
        orderBy: { createdAt: "desc" },
        skip: (p.page - 1) * p.limit,
        take: p.limit,
      }),
      prisma.tripStory.count(),
    ]);
    return { items, total };
  },

  create(data: CreateStoryData): Promise<StoryWithAuthor> {
    return prisma.tripStory.create({
      data: {
        userId: data.userId,
        content: data.content,
        images: data.images,
        bookingId: data.bookingId,
      },
      include: STORY_INCLUDE,
    });
  },

  findById(id: string): Promise<StoryWithAuthor | null> {
    return prisma.tripStory.findUnique({
      where: { id },
      include: STORY_INCLUDE,
    });
  },

  // Tăng bộ đếm like 1 đơn vị; trả về story đã cập nhật (kèm tác giả).
  incrementLikes(id: string): Promise<StoryWithAuthor> {
    return prisma.tripStory.update({
      where: { id },
      data: { likes: { increment: 1 } },
      include: STORY_INCLUDE,
    });
  },
};
