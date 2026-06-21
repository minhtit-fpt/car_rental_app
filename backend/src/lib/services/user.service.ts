import { Prisma, type User, type KycStatus, type UserRole } from "@prisma/client";
import { AppError } from "@/lib/errors/app-error";
import { userRepository } from "@/lib/repositories/user.repository";
import type { UpdateProfileInput } from "@/lib/validators/user.validator";

export interface PublicUser {
  id: string;
  phone: string;
  email: string | null;
  name: string | null;
  roles: UserRole[];
  kycStatus: KycStatus;
}

function toPublicUser(user: User): PublicUser {
  return {
    id: user.id,
    phone: user.phone,
    email: user.email,
    name: user.name,
    roles: user.roles,
    kycStatus: user.kycStatus,
  };
}

export const userService = {
  async updateProfile(
    userId: string,
    input: UpdateProfileInput,
  ): Promise<PublicUser> {
    try {
      const updated = await userRepository.updateProfile(userId, {
        ...(input.email !== undefined && { email: input.email }),
        ...(input.name !== undefined && { name: input.name }),
      });
      return toPublicUser(updated);
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === "P2002"
      ) {
        throw new AppError(409, "EMAIL_TAKEN", "Email đã được sử dụng");
      }
      throw error;
    }
  },
};
