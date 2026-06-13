import type { RefreshToken } from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho RefreshToken — chỉ lưu/đọc theo tokenHash.

export interface CreateRefreshTokenInput {
  userId: string;
  tokenHash: string;
  expiresAt: Date;
}

export const refreshTokenRepository = {
  create(input: CreateRefreshTokenInput): Promise<RefreshToken> {
    return prisma.refreshToken.create({ data: input });
  },

  findByHash(tokenHash: string): Promise<RefreshToken | null> {
    return prisma.refreshToken.findUnique({ where: { tokenHash } });
  },

  revoke(id: string): Promise<RefreshToken> {
    return prisma.refreshToken.update({
      where: { id },
      data: { revokedAt: new Date() },
    });
  },

  async revokeAllForUser(userId: string): Promise<number> {
    const result = await prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    return result.count;
  },
};
