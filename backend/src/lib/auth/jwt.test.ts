import { beforeEach, describe, expect, it } from "vitest";
import { KycStatus, UserRole } from "@prisma/client";
import { signAccessToken, verifyAccessToken } from "@/lib/auth/jwt";

beforeEach(() => {
  process.env.DATABASE_URL = "postgresql://u:p@localhost:5432/db";
  process.env.REDIS_URL = "redis://localhost:6379";
  process.env.JWT_ACCESS_SECRET = "x".repeat(40);
  process.env.JWT_ACCESS_TTL = "15m";
});

describe("access token", () => {
  it("signs and verifies, round-tripping claims", async () => {
    const token = await signAccessToken({
      sub: "user-123",
      roles: [UserRole.RENTER],
      kycStatus: KycStatus.UNVERIFIED,
    });

    const decoded = await verifyAccessToken(token);

    expect(decoded.sub).toBe("user-123");
    expect(decoded.roles).toEqual([UserRole.RENTER]);
    expect(decoded.kycStatus).toBe(KycStatus.UNVERIFIED);
  });

  it("rejects a tampered token", async () => {
    const token = await signAccessToken({
      sub: "user-1",
      roles: [UserRole.RENTER],
      kycStatus: KycStatus.UNVERIFIED,
    });

    await expect(verifyAccessToken(`${token}tampered`)).rejects.toThrow();
  });

  it("rejects a token signed with a different secret", async () => {
    const token = await signAccessToken({
      sub: "user-1",
      roles: [UserRole.OWNER],
      kycStatus: KycStatus.VERIFIED,
    });

    process.env.JWT_ACCESS_SECRET = "y".repeat(40);

    await expect(verifyAccessToken(token)).rejects.toThrow();
  });
});
