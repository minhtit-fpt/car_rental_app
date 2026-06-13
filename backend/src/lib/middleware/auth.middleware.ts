import { verifyAccessToken, type AccessTokenClaims } from "@/lib/auth/jwt";
import { AppError } from "@/lib/errors/app-error";

const BEARER_PREFIX = "Bearer ";

// Bắt buộc access token hợp lệ. Trả claims hoặc ném AppError(401).
export async function requireAuth(req: Request): Promise<AccessTokenClaims> {
  const header = req.headers.get("authorization");
  if (!header || !header.startsWith(BEARER_PREFIX)) {
    throw new AppError(401, "UNAUTHORIZED", "Thiếu access token");
  }

  const token = header.slice(BEARER_PREFIX.length).trim();
  try {
    return await verifyAccessToken(token);
  } catch {
    throw new AppError(
      401,
      "UNAUTHORIZED",
      "Access token không hợp lệ hoặc đã hết hạn",
    );
  }
}
