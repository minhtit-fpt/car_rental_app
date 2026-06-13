import { createHash, randomBytes } from "node:crypto";
import { getEnv } from "@/lib/config/env";

// Refresh token là chuỗi opaque ngẫu nhiên. DB chỉ lưu SHA-256 hash
// (RefreshToken.tokenHash) — không bao giờ lưu token gốc.

const TOKEN_BYTES = 48;
const DAY_MS = 24 * 60 * 60 * 1000;

export interface GeneratedRefreshToken {
  token: string; // opaque, trả về cho client
  tokenHash: string; // SHA-256 hex, lưu DB
  expiresAt: Date;
}

export function hashRefreshToken(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}

export function generateRefreshToken(): GeneratedRefreshToken {
  const token = randomBytes(TOKEN_BYTES).toString("base64url");
  const expiresAt = new Date(
    Date.now() + getEnv().JWT_REFRESH_TTL_DAYS * DAY_MS,
  );

  return { token, tokenHash: hashRefreshToken(token), expiresAt };
}
