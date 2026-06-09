import Redis from "ioredis";
import { getEnv } from "@/lib/config/env";

// Redis singleton — tránh nhiều kết nối khi hot-reload. lazyConnect để không
// kết nối lúc import (an toàn khi build). Dùng cho rate limiting.
const globalForRedis = globalThis as unknown as {
  redis: Redis | undefined;
};

export const redis =
  globalForRedis.redis ??
  new Redis(getEnv().REDIS_URL, {
    lazyConnect: true,
    maxRetriesPerRequest: 2,
  });

if (process.env.NODE_ENV !== "production") {
  globalForRedis.redis = redis;
}
