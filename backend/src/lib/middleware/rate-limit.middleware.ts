import { redis } from "@/db/redis";
import { AppError } from "@/lib/errors/app-error";

// Fixed-window counter trên Redis. Vượt ngưỡng → AppError(429).
export async function enforceRateLimit(
  key: string,
  limit: number,
  windowSeconds: number,
): Promise<void> {
  const redisKey = `ratelimit:${key}`;
  const count = await redis.incr(redisKey);

  if (count === 1) {
    await redis.expire(redisKey, windowSeconds);
  }

  if (count > limit) {
    throw new AppError(
      429,
      "RATE_LIMITED",
      "Quá nhiều yêu cầu, vui lòng thử lại sau",
    );
  }
}
