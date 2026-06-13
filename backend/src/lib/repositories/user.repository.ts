import type { KycStatus, Prisma, User } from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho User — CHỈ nơi đây gọi Prisma cho bảng User.

export const userRepository = {
  findByPhone(phone: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { phone } });
  },

  findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { id } });
  },

  create(data: Prisma.UserCreateInput): Promise<User> {
    return prisma.user.create({ data });
  },

  updateKycStatus(id: string, kycStatus: KycStatus): Promise<User> {
    return prisma.user.update({ where: { id }, data: { kycStatus } });
  },

  updateProfile(
    id: string,
    data: Pick<Prisma.UserUpdateInput, "email">,
  ): Promise<User> {
    return prisma.user.update({ where: { id }, data });
  },
};
