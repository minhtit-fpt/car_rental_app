import { beforeEach, describe, expect, it } from "vitest";
import {
  generateRefreshToken,
  hashRefreshToken,
} from "@/lib/auth/refresh-token";

const DAY_MS = 24 * 60 * 60 * 1000;

beforeEach(() => {
  process.env.DATABASE_URL = "postgresql://u:p@localhost:5432/db";
  process.env.REDIS_URL = "redis://localhost:6379";
  process.env.JWT_ACCESS_SECRET = "x".repeat(40);
  process.env.JWT_REFRESH_TTL_DAYS = "30";
});

describe("refresh token", () => {
  it("generates an opaque token with a matching sha256 hash", () => {
    const { token, tokenHash } = generateRefreshToken();

    expect(token.length).toBeGreaterThan(40);
    expect(tokenHash).toBe(hashRefreshToken(token));
    expect(tokenHash).toMatch(/^[a-f0-9]{64}$/);
  });

  it("sets expiresAt in the future according to TTL days", () => {
    const { expiresAt } = generateRefreshToken();
    const days = (expiresAt.getTime() - Date.now()) / DAY_MS;

    expect(days).toBeGreaterThan(29);
    expect(days).toBeLessThanOrEqual(30);
  });

  it("produces unique tokens on each call", () => {
    expect(generateRefreshToken().token).not.toBe(
      generateRefreshToken().token,
    );
  });
});
