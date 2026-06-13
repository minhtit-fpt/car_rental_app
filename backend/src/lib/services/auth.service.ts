import type { KycStatus, User, UserRole } from "@prisma/client";
import { hashPassword, verifyPassword } from "@/lib/auth/password";
import { signAccessToken } from "@/lib/auth/jwt";
import {
  generateRefreshToken,
  hashRefreshToken,
} from "@/lib/auth/refresh-token";
import { userRepository } from "@/lib/repositories/user.repository";
import { refreshTokenRepository } from "@/lib/repositories/refresh-token.repository";
import { AppError } from "@/lib/errors/app-error";
import type {
  LoginInput,
  RegisterInput,
} from "@/lib/validators/auth.validator";

export interface PublicUser {
  id: string;
  phone: string;
  email: string | null;
  roles: UserRole[];
  kycStatus: KycStatus;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface AuthResult {
  user: PublicUser;
  tokens: AuthTokens;
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

// Phát access token + tạo + lưu refresh token (chỉ lưu hash).
async function issueTokens(user: User): Promise<AuthTokens> {
  const accessToken = await signAccessToken({
    sub: user.id,
    roles: user.roles,
    kycStatus: user.kycStatus,
  });

  const { token, tokenHash, expiresAt } = generateRefreshToken();
  await refreshTokenRepository.create({
    userId: user.id,
    tokenHash,
    expiresAt,
  });

  return { accessToken, refreshToken: token };
}

export const authService = {
  async register(input: RegisterInput): Promise<AuthResult> {
    const existing = await userRepository.findByPhone(input.phone);
    if (existing) {
      throw new AppError(409, "PHONE_TAKEN", "Số điện thoại đã được đăng ký");
    }

    const passwordHash = await hashPassword(input.password);
    // KHÔNG nhận roles từ client — dùng default [RENTER] của schema.
    const user = await userRepository.create({
      phone: input.phone,
      email: input.email,
      passwordHash,
    });

    return { user: toPublicUser(user), tokens: await issueTokens(user) };
  },

  async login(input: LoginInput): Promise<AuthResult> {
    const user = await userRepository.findByPhone(input.phone);
    // Cùng một thông báo cho cả 2 trường hợp để tránh lộ user tồn tại.
    if (!user || !(await verifyPassword(input.password, user.passwordHash))) {
      throw new AppError(
        401,
        "INVALID_CREDENTIALS",
        "Số điện thoại hoặc mật khẩu không đúng",
      );
    }

    return { user: toPublicUser(user), tokens: await issueTokens(user) };
  },

  async refresh(refreshToken: string): Promise<AuthTokens> {
    const tokenHash = hashRefreshToken(refreshToken);
    const stored = await refreshTokenRepository.findByHash(tokenHash);

    if (!stored) {
      throw new AppError(
        401,
        "INVALID_REFRESH_TOKEN",
        "Refresh token không hợp lệ",
      );
    }

    // Reuse detection: token đã thu hồi mà vẫn được dùng lại → nghi bị lộ,
    // thu hồi TẤT CẢ token của user.
    if (stored.revokedAt) {
      await refreshTokenRepository.revokeAllForUser(stored.userId);
      throw new AppError(
        401,
        "INVALID_REFRESH_TOKEN",
        "Refresh token đã bị thu hồi",
      );
    }

    if (stored.expiresAt.getTime() <= Date.now()) {
      throw new AppError(
        401,
        "INVALID_REFRESH_TOKEN",
        "Refresh token đã hết hạn",
      );
    }

    const user = await userRepository.findById(stored.userId);
    if (!user) {
      throw new AppError(
        401,
        "INVALID_REFRESH_TOKEN",
        "Người dùng không tồn tại",
      );
    }

    // Rotation: thu hồi token cũ rồi phát cặp token mới.
    await refreshTokenRepository.revoke(stored.id);
    return issueTokens(user);
  },

  // Idempotent — không lỗi nếu token không tồn tại hoặc đã thu hồi.
  async logout(refreshToken: string): Promise<void> {
    const stored = await refreshTokenRepository.findByHash(
      hashRefreshToken(refreshToken),
    );
    if (stored && !stored.revokedAt) {
      await refreshTokenRepository.revoke(stored.id);
    }
  },

  async getCurrentUser(userId: string): Promise<PublicUser> {
    const user = await userRepository.findById(userId);
    if (!user) {
      throw new AppError(404, "USER_NOT_FOUND", "Không tìm thấy người dùng");
    }
    return toPublicUser(user);
  },
};
