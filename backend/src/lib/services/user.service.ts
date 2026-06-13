import { Prisma, type User, type KycStatus, type UserRole } from "@prisma/client";
import { AppError } from "@/lib/errors/app-error";
import { userRepository } from "@/lib/repositories/user.repository";
import type { UpdateProfileInput } from "@/lib/validators/user.validator";

export interface PublicUser {
  id: string;
  phone: string;
  email: string | null;
  roles: UserRole[];
  kycStatus: KycStatus;
}

function toPublicUser(user: User): PublicUser {
  return {
    id: user.id,
    phone: user.phone,
    email: user.email,
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
        email: input.email,
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
