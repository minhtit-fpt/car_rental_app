import { type Prisma } from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho Favorite (xe đã lưu) — CHỈ nơi đây gọi Prisma.
// Cột Vehicle.location là Unsupported(geography) nên Prisma tự bỏ qua khi include.

const FAVORITE_INCLUDE = {
  vehicle: { include: { owner: { select: { name: true } } } },
} satisfies Prisma.FavoriteInclude;

export type FavoriteWithVehicle = Prisma.FavoriteGetPayload<{
  include: typeof FAVORITE_INCLUDE;
}>;

export const favoriteRepository = {
  // Idempotent: thêm vào yêu thích, không lỗi nếu đã tồn tại (unique userId+vehicleId).
  async add(userId: string, vehicleId: string): Promise<void> {
    await prisma.favorite.upsert({
      where: { userId_vehicleId: { userId, vehicleId } },
      create: { userId, vehicleId },
      update: {},
    });
  },

  // Idempotent: bỏ yêu thích, không lỗi nếu chưa có.
  async remove(userId: string, vehicleId: string): Promise<void> {
    await prisma.favorite.deleteMany({ where: { userId, vehicleId } });
  },

  // Danh sách xe đã lưu của user (mới lưu trước), kèm tên chủ xe.
  findByUser(userId: string): Promise<FavoriteWithVehicle[]> {
    return prisma.favorite.findMany({
      where: { userId },
      include: FAVORITE_INCLUDE,
      orderBy: { createdAt: "desc" },
    });
  },
};
