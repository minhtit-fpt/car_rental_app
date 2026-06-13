import { beforeEach, describe, expect, it, vi } from "vitest";
import { KycStatus, UserRole, type User } from "@prisma/client";

vi.mock("@/lib/repositories/user.repository", () => ({
  userRepository: {
    findByPhone: vi.fn(),
    findById: vi.fn(),
    create: vi.fn(),
  },
}));

vi.mock("@/lib/repositories/refresh-token.repository", () => ({
  refreshTokenRepository: {
    create: vi.fn(),
    findByHash: vi.fn(),
    revoke: vi.fn(),
    revokeAllForUser: vi.fn(),
  },
}));

vi.mock("@/lib/auth/password", () => ({
  hashPassword: vi.fn(async () => "hashed-password"),
  verifyPassword: vi.fn(),
}));

vi.mock("@/lib/auth/jwt", () => ({
  signAccessToken: vi.fn(async () => "access.jwt.token"),
}));

vi.mock("@/lib/auth/refresh-token", () => ({
  generateRefreshToken: vi.fn(() => ({
    token: "raw-refresh",
    tokenHash: "hash-of-raw",
    expiresAt: new Date(Date.now() + 60_000),
  })),
  hashRefreshToken: vi.fn((token: string) => `hash:${token}`),
}));

import { authService } from "@/lib/services/auth.service";
import { AppError } from "@/lib/errors/app-error";
import { userRepository } from "@/lib/repositories/user.repository";
import { refreshTokenRepository } from "@/lib/repositories/refresh-token.repository";
import { verifyPassword } from "@/lib/auth/password";

function makeUser(overrides: Partial<User> = {}): User {
  return {
    id: "user-1",
    phone: "+84901234567",
    email: null,
    passwordHash: "hashed-password",
    roles: [UserRole.RENTER],
    kycStatus: KycStatus.UNVERIFIED,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}

beforeEach(() => {
  vi.clearAllMocks();
});

describe("authService.register", () => {
  it("creates a user and returns tokens without the password hash", async () => {
    vi.mocked(userRepository.findByPhone).mockResolvedValue(null);
    vi.mocked(userRepository.create).mockResolvedValue(makeUser());

    const result = await authService.register({
      phone: "+84901234567",
      password: "password1",
    });

    expect(userRepository.create).toHaveBeenCalledWith({
      phone: "+84901234567",
      email: undefined,
      passwordHash: "hashed-password",
    });
    expect(result.tokens.accessToken).toBe("access.jwt.token");
    expect(result.tokens.refreshToken).toBe("raw-refresh");
    expect(result.user).not.toHaveProperty("passwordHash");
    expect(result.user.roles).toEqual([UserRole.RENTER]);
  });

  it("throws 409 PHONE_TAKEN when phone exists", async () => {
    vi.mocked(userRepository.findByPhone).mockResolvedValue(makeUser());

    await expect(
      authService.register({ phone: "+84901234567", password: "password1" }),
    ).rejects.toMatchObject({ status: 409, code: "PHONE_TAKEN" });
  });
});

describe("authService.login", () => {
  it("returns tokens on valid credentials", async () => {
    vi.mocked(userRepository.findByPhone).mockResolvedValue(makeUser());
    vi.mocked(verifyPassword).mockResolvedValue(true);

    const result = await authService.login({
      phone: "+84901234567",
      password: "password1",
    });

    expect(result.tokens.accessToken).toBe("access.jwt.token");
    expect(refreshTokenRepository.create).toHaveBeenCalledOnce();
  });

  it("throws 401 when user not found", async () => {
    vi.mocked(userRepository.findByPhone).mockResolvedValue(null);

    await expect(
      authService.login({ phone: "+84901234567", password: "x" }),
    ).rejects.toMatchObject({ status: 401, code: "INVALID_CREDENTIALS" });
  });

  it("throws 401 on wrong password", async () => {
    vi.mocked(userRepository.findByPhone).mockResolvedValue(makeUser());
    vi.mocked(verifyPassword).mockResolvedValue(false);

    await expect(
      authService.login({ phone: "+84901234567", password: "wrong" }),
    ).rejects.toMatchObject({ status: 401, code: "INVALID_CREDENTIALS" });
  });
});

describe("authService.refresh", () => {
  it("rotates: revokes the old token and issues a new pair", async () => {
    vi.mocked(refreshTokenRepository.findByHash).mockResolvedValue({
      id: "rt-1",
      userId: "user-1",
      tokenHash: "hash:old",
      expiresAt: new Date(Date.now() + 60_000),
      revokedAt: null,
      createdAt: new Date(),
    });
    vi.mocked(userRepository.findById).mockResolvedValue(makeUser());

    const tokens = await authService.refresh("old");

    expect(refreshTokenRepository.revoke).toHaveBeenCalledWith("rt-1");
    expect(refreshTokenRepository.create).toHaveBeenCalledOnce();
    expect(tokens.refreshToken).toBe("raw-refresh");
  });

  it("throws 401 when token not found", async () => {
    vi.mocked(refreshTokenRepository.findByHash).mockResolvedValue(null);

    await expect(authService.refresh("nope")).rejects.toMatchObject({
      status: 401,
      code: "INVALID_REFRESH_TOKEN",
    });
  });

  it("detects reuse: revokes ALL user tokens when a revoked token is replayed", async () => {
    vi.mocked(refreshTokenRepository.findByHash).mockResolvedValue({
      id: "rt-2",
      userId: "user-9",
      tokenHash: "hash:reused",
      expiresAt: new Date(Date.now() + 60_000),
      revokedAt: new Date(),
      createdAt: new Date(),
    });

    await expect(authService.refresh("reused")).rejects.toMatchObject({
      status: 401,
    });
    expect(refreshTokenRepository.revokeAllForUser).toHaveBeenCalledWith(
      "user-9",
    );
  });

  it("throws 401 when token is expired", async () => {
    vi.mocked(refreshTokenRepository.findByHash).mockResolvedValue({
      id: "rt-3",
      userId: "user-1",
      tokenHash: "hash:expired",
      expiresAt: new Date(Date.now() - 1000),
      revokedAt: null,
      createdAt: new Date(),
    });

    await expect(authService.refresh("expired")).rejects.toMatchObject({
      status: 401,
    });
    expect(refreshTokenRepository.revoke).not.toHaveBeenCalled();
  });
});

describe("authService.logout", () => {
  it("revokes an active token", async () => {
    vi.mocked(refreshTokenRepository.findByHash).mockResolvedValue({
      id: "rt-1",
      userId: "user-1",
      tokenHash: "hash:tok",
      expiresAt: new Date(Date.now() + 60_000),
      revokedAt: null,
      createdAt: new Date(),
    });

    await authService.logout("tok");

    expect(refreshTokenRepository.revoke).toHaveBeenCalledWith("rt-1");
  });

  it("is idempotent when token is absent", async () => {
    vi.mocked(refreshTokenRepository.findByHash).mockResolvedValue(null);

    await expect(authService.logout("missing")).resolves.toBeUndefined();
    expect(refreshTokenRepository.revoke).not.toHaveBeenCalled();
  });
});

describe("authService.getCurrentUser", () => {
  it("returns the public user", async () => {
    vi.mocked(userRepository.findById).mockResolvedValue(makeUser());

    const user = await authService.getCurrentUser("user-1");

    expect(user.id).toBe("user-1");
    expect(user).not.toHaveProperty("passwordHash");
  });

  it("throws 404 when not found", async () => {
    vi.mocked(userRepository.findById).mockResolvedValue(null);

    await expect(authService.getCurrentUser("ghost")).rejects.toMatchObject({
      status: 404,
      code: "USER_NOT_FOUND",
    });
  });
});
