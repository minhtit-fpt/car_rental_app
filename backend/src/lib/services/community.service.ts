import { AppError } from "@/lib/errors/app-error";
import {
  communityRepository,
  type StoryWithAuthor,
} from "@/lib/repositories/community.repository";
import type {
  CreateStoryInput,
  ListStoriesQuery,
} from "@/lib/validators/community.validator";

export interface PublicStory {
  id: string;
  authorId: string;
  authorName: string;
  content: string;
  images: string[];
  likes: number;
  bookingId: string | null;
  createdAt: string;
}

export interface StoryListResult {
  items: PublicStory[];
  total: number;
  page: number;
  limit: number;
}

// User không có trường tên — hiển thị phần đầu email, nếu không có thì che số ĐT.
function displayName(user: {
  phone: string;
  email: string | null;
}): string {
  if (user.email) {
    return user.email.split("@")[0] ?? user.email;
  }
  const p = user.phone;
  return p.length > 4 ? `***${p.slice(-4)}` : p;
}

function toPublic(s: StoryWithAuthor): PublicStory {
  return {
    id: s.id,
    authorId: s.userId,
    authorName: displayName(s.user),
    content: s.content,
    images: s.images,
    likes: s.likes,
    bookingId: s.bookingId,
    createdAt: s.createdAt.toISOString(),
  };
}

export const communityService = {
  async list(query: ListStoriesQuery): Promise<StoryListResult> {
    const { items, total } = await communityRepository.findMany(query);
    return {
      items: items.map(toPublic),
      total,
      page: query.page,
      limit: query.limit,
    };
  },

  async create(userId: string, input: CreateStoryInput): Promise<PublicStory> {
    const story = await communityRepository.create({
      userId,
      content: input.content,
      images: input.images,
      bookingId: input.bookingId,
    });
    return toPublic(story);
  },

  async like(id: string): Promise<PublicStory> {
    const existing = await communityRepository.findById(id);
    if (!existing) {
      throw new AppError(404, "STORY_NOT_FOUND", "Không tìm thấy bài viết");
    }
    return toPublic(await communityRepository.incrementLikes(id));
  },
};
